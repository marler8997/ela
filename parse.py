import lex

EOF = 1
CALL = 2
STRING = 3
NUMBER = 4
MACRO = 5
SYMBOL_REFERENCE = 6
FUNCTION_DEF = 7
BUILTIN_SYMBOL = 8
DOTTED_MEMBER = 9
MEMOIZE = 10

class Node:
    def __init__(self, kind):
        self.kind = kind
    def __str__(self):
        return "Node({})".format(self.kind)
    # getToken returns the first token for this node mainly meant to point at this
    # node for error messages

class CallNode(Node):
    def __init__(self, fnExpr, leftParenToken, argNodes, rightParenToken):
        Node.__init__(self, CALL)
        self.fnExpr = fnExpr
        self.leftParenToken = leftParenToken
        self.argNodes = argNodes
        self.rightParenToken = rightParenToken
    def getToken(self):
        return self.fnExpr.getToken()
    def desc(self, str):
        return "(Call fn={} args: {})".format(self.fnExpr.desc(str),
                                              " ".join([argNode.desc(str) for argNode in self.argNodes]))

class MacroNode(Node):
    def __init__(self, macroToken, idToken, id, expr):
        Node.__init__(self, MACRO)
        self.macroToken = macroToken
        self.idToken = idToken
        self.id = id
        self.expr = expr
    def getToken(self):
        return self.macroToken
    def desc(self, str):
        return "({} {} {})".format("Macro", self.id, self.expr.desc(str))

class MemoizeNode(Node):
    def __init__(self, memoizeToken, idToken, id, expr):
        Node.__init__(self, MEMOIZE)
        self.memoizeToken = memoizeToken
        self.idToken = idToken
        self.id = id
        self.expr = expr
    def getToken(self):
        return self.memoizeToken
    def desc(self, str):
        return "({} {} {})".format("Memoize", self.id, self.expr.desc(str))

class StringNode(Node):
    def __init__(self, token: lex.StringToken):
        Node.__init__(self, STRING)
        self.token = token
    def getToken(self):
        return self.token
    def desc(self, str):
        return "(String {})".format(str[self.token.start:self.token.end])

class NumberNode(Node):
    def __init__(self, token: lex.Token, value: int):
        Node.__init__(self, NUMBER)
        self.token = token
        self.value = value
    def getToken(self):
        return self.token
    def desc(self, str):
        return "(Number {})".format(self.value)

class SymbolReferenceNode(Node):
    def __init__(self, idToken, id):
        Node.__init__(self, SYMBOL_REFERENCE)
        self.idToken = idToken
        self.id = id
    def getToken(self):
        return self.idToken
    def desc(self, str):
        return "(SymbolReference {})".format(self.id)

class BuiltinSymbolNode(Node):
    def __init__(self, idToken, id):
        Node.__init__(self, BUILTIN_SYMBOL)
        self.idToken = idToken
        self.id = id
    def getToken(self):
        return self.idToken
    def desc(self, str):
        return "(BuiltinSymbol @{})".format(self.id)

ABI_NONE = 0
ABI_START = 1
ABI_SYSCALL = 2

class FunctionNode(Node):
    def __init__(self, fnToken, attrs, body):
        Node.__init__(self, FUNCTION_DEF)
        self.fnToken = fnToken
        self.attrs = attrs
        self.body = body
    def getToken(self):
        return self.fnToken
    def desc(self, str):
        return "(FunctionNode)"

class DottedMemberNode(Node):
    def __init__(self, objNode, dotToken, memberToken, member):
        Node.__init__(self, DOTTED_MEMBER)
        self.objNode = objNode
        self.dotToken = dotToken
        self.memberToken = memberToken
        self.member = member
    def getToken(self):
        return self.objNode.getToken()
    def desc(self, str):
        return "(DottedMember '{}' of {})".format(self.member, self.objNode.desc(str))

CONTEXT_TOP_LEVEL = 0
CONTEXT_ARGUMENT = 1
CONTEXT_MACRO_MEMOIZE = 2
CONTEXT_FN_ATTRIBUTE = 3
CONTEXT_FN_BODY = 4
CONTEXT_DOTTED_MEMBER = 5

class Parser:
    def __init__(self, lexer: lex.Lexer):
        self.lexer = lexer
        self.lookahead = []
        self.str = lexer.reader.str

    def peekToken(self):
        if not self.lookahead:
            self.lookahead.append(self.lexer.lexToken())
        return self.lookahead[0]

    def popToken(self):
        assert(self.lookahead)
        self.lookahead.pop(0)

    def errAt(self, token, msg):
        self.lexer.errAt(token.start, msg)

    def parseInto(self, expressions):
        while True:
            node = self.parseExpression(CONTEXT_TOP_LEVEL)
            #print("got node {}".format(node))
            if node.kind == EOF:
                break
            expressions.append(node)

    # Currently, we are able to fully parse an expression and determine the end of it
    # without knowing the outer-context by only looking ahead at 1 token.  This is a nice property
    # because it means that we can just invoke the parseExpression function without needing
    # extra delimiters in each context to separate expressions.  For example, in a block of code we don't
    # need extra delimiters for every statement, and in a function call we don't need delimiters between
    # arguments.
    def parseExpression(self, context):
        part = self.parseExpressionPart(context)
        if part.kind == EOF:
            return part
        while True:
            nextToken = self.peekToken()
            if nextToken.kind == lex.LEFT_PAREN:
                self.popToken()
                part = self.parseCall(part, nextToken)
            elif nextToken.kind == lex.DOT:
                self.popToken()
                memberToken = self.peekToken()
                memberStr = self.str[memberToken.start:memberToken.end]
                if memberToken.kind != lex.ID:
                    self.errAt(memberToken, "expected ID after '.', but got '{}'".format("EOF" if memberToken.kind == lex.EOF else memberStr))
                self.popToken()
                part = DottedMemberNode(part, nextToken, memberToken, memberStr)
            else:
                break
        return part

    def parseExpressionPart(self, context):
        nextToken = self.peekToken()
        #print("[DEBUG] parseExpressionPart token={}".format(nextToken.desc(self.str)))
        if nextToken.kind == lex.EOF:
            if context == CONTEXT_TOP_LEVEL:
                self.popToken()
                return Node(EOF)
            self.errAt(nextToken, "expected expression (context={}) but got EOF".format(context))
        self.popToken()
        if nextToken.kind == lex.AT:
            idToken = self.peekToken()
            self.popToken()
            if idToken.kind != lex.ID:
                self.errAt(idToken, "'@' must be followed by an ID token but got '{}'".format(lex.ID, idToken.desc(self.str)))
            return BuiltinSymbolNode(idToken, self.str[idToken.start:idToken.end])
        if nextToken.kind == lex.ID:
            id = self.str[nextToken.start:nextToken.end]
            if id == "fn":
                return self.parseFn(nextToken)
            # macro and memoize are only allowed at statement-level context because all they do is create a symbol entry,
            # for the purpose of using a value multiple times, so there's not much reason to support it at the expression
            # level.  Forbiding this make code more maintainable because developers always know where to find macro and
            # memoize statements, they will never be hiddn inside an expression.
            if id == "macro":
                if context != CONTEXT_TOP_LEVEL and context != CONTEXT_FN_BODY:
                    self.errAt(nextToken, "macro is only allowed at statement-level context (context={})".format(context))
                return self.parseMacroMemoize(MacroNode, nextToken)
            # Note: memoize can't be a builtin function because it needs to prevent it's input expression
            #       from being evaluated like all builtin function arguments are done
            #       The point of memoize is to prevent the expression from being evaulated more than once, so it
            #       only makes sense if you are assigning it to a name so it can be used more than once.
            #       So memoize works just like macro, except it memoizes the expression so it is only evaluated once.
            if id == "memoize":
                if context != CONTEXT_TOP_LEVEL and context != CONTEXT_FN_BODY:
                    self.errAt(nextToken, "memoize is only allowed at statement-level context (context={})".format(context))
                return self.parseMacroMemoize(MemoizeNode, nextToken)
            return SymbolReferenceNode(nextToken, id)
        if nextToken.kind == lex.STRING:
            return StringNode(nextToken)
        if nextToken.kind == lex.NUMBER:
            return NumberNode(nextToken, int(self.str[nextToken.start:nextToken.end]))

        self.errAt(nextToken, "unable to parse expression from token {}".format(nextToken.desc(self.str)))

    def parseMacroMemoize(self, NodeClass, keywordToken):
        idToken = self.peekToken()
        if idToken.kind != lex.ID:
            self.errAt(idToken, "expected an ID token after 'macro' but got {}".format(idToken.desc(self.str)))
        self.popToken()
        return NodeClass(keywordToken, idToken, self.str[idToken.start:idToken.end],
                         self.parseExpression(CONTEXT_MACRO_MEMOIZE))

    def parseCall(self, fnExpr: Node, leftParenToken: lex.Token):
        argNodes = []
        while True:
            nextToken = self.peekToken()
            if nextToken.kind == lex.RIGHT_PAREN:
                self.popToken()
                return CallNode(fnExpr, leftParenToken, argNodes, nextToken)
            argNodes.append(self.parseExpression(CONTEXT_ARGUMENT))

    def parseFnAttribute(self, token, attrs):
        tokenStr = self.str[token.start:token.end]
        if token.kind == lex.ID:
            if tokenStr == "link":
                attrs.link = True
                return
            if tokenStr == "abiStart":
                attrs.abi = ABI_START
                return
            if tokenStr == "abiSyscall":
                attrs.abi = ABI_SYSCALL
                countToken = self.peekToken()
                self.popToken()
                countStr = self.str[countToken.start:countToken.end]
                if countToken.kind != lex.NUMBER:
                    self.errAt(countToken, "expected a NUMBER after abiSyscall but got '{}'".format(countStr))
                attrs.syscallCount = int(countStr)
                return
        self.errAt(token, "invalid function attribute '{}'".format(tokenStr))

    def parseFn(self, fnExpr):
        class FunctionAttributes:
            def __init__(self):
                self.link = False
                self.abi = ABI_NONE
                self.syscallCount = None
        attrs = FunctionAttributes()

        # parse function attributes
        while True:
            nextToken = self.peekToken()
            self.popToken()
            #if nextToken.kind == lex.LEFT_PAREN:
            if nextToken.kind == lex.LEFT_CURLY:
                break
            self.parseFnAttribute(nextToken, attrs)
            if attrs.link:
                return FunctionNode(fnExpr, attrs, None)

        # NOTE: for now I'm not going to implement an arg list or arg types, not sure how they should be implemented yet
        #paramIds = []
        #while True:
        #    nextToken = self.peekToken()
        #    self.popToken()
        #    if nextToken.kind == lex.RIGHT_PAREN:
        #        break
        #    #if nextToken.kind != lex.ID:
        #    #    self.errAt(nextToken, "fn params currenly only support ID tokens but got {}".format(nextToken.desc(self.str)))
        #    #paramIds.append(self.str[nextToken.start:nextToken.end])

        # NOTE: we could parse a return type here, but for now it doesn't seem necessary because the return type
        #       can be inferred from the function body. It seems like the only purpose for a return type is to assure
        #       the maintainer that the function always returns a particular type.  This assurance may be useful, however,
        #       there may be better ways to fulfill this assurance rather than declaring the return type for functions that
        #       have a body.
        #       Maybe there will be a general solution for programmer "assurances".  It might be better to separate code
        #       that is meant to make the program work and code that is meant to provide assurnaces to the maintainer.
        #returnType = parseExpression(CONTEXT_RETURN_TYPE)

        #nextToken = self.peekToken()
        #self.popToken()
        if nextToken.kind != lex.LEFT_CURLY:
            self.errAt(nextToken, "expected left curly brace '{{' but got {}".format(nextToken.desc(self.str)))

        body = []
        while True:
            nextToken = self.peekToken()
            if nextToken.kind == lex.RIGHT_CURLY:
                self.popToken()
                break
            expr = self.parseExpression(CONTEXT_FN_BODY)
            body.append(expr)

        return FunctionNode(fnExpr, attrs, body)
