ID          = 0
NUMBER      = 1
LEFT_PAREN  = 2
RIGHT_PAREN = 3
LEFT_CURLY  = 4
RIGHT_CURLY = 5
PIPE        = 6
TILDA       = 7
EOF         = 8
CHAR_OUT_OF_RANGE = 9
INVALID_CHAR = 10
AT          = 11
COMMA       = 12
STRING      = 13
DOT         = 14

class Token:
    def __init__(self, kind, start, end):
        self.kind = kind
        self.start = start
        self.end = end
    def desc(self, str):
        if self.kind == EOF:
            return "EOF"
        if self.kind == ID:
            return "ID({})".format(str[self.start:self.end])
        if self.kind == INVALID_CHAR:
            return "INVALID_CHAR({})".format(str[self.start:self.start+1])
        if self.kind == LEFT_CURLY:
            return "LEFT_CURLY '{'"
        if self.kind == COMMA:
            return "COMMA"
        return "Token(kind={})".format(self.kind)

class StringToken(Token):
    def __init__(self, start, end, value):
        Token.__init__(self, STRING, start, end)
        self.value = value
    def desc(self, str):
        return "STRING {}".format(str[self.start:self.end])

class NumberToken(Token):
    def __init__(self, start, end, value):
        Token.__init__(self, NUMBER, start, end)
        self.value = value
    def desc(self, str):
        return "NUMBER {}".format(str[self.start:self.end])

def popSingleCharToken(reader, kind):
    start = reader.getPosition()
    reader.pop()
    return Token(kind, start, reader.getPosition())

class SyntaxError(Exception):
    pass

class Lexer:
    def __init__(self, reader):
        self.reader = reader

    def errAt(self, pos, msg):
        raise SyntaxError(self.reader.errorMessagePrefix(pos) + msg)

    def lexToken(self):
        gotCharFromSkipTrivial, c = self.skipTrivial()
        if not gotCharFromSkipTrivial:
            return Token(EOF, self.reader.getPosition(), self.reader.getPosition())

        if c >= ord('a'):
            if c <= ord('z'):
                return lexId(self.reader)
            if c == ord('{'):
                return popSingleCharToken(self.reader, LEFT_CURLY)
            if c == ord('}'):
                return popSingleCharToken(self.reader, RIGHT_CURLY)
            if c == ord('|'):
                return popSingleCharToken(self.reader, PIPE)
            if c == ord('~'):
                return popSingleCharToken(self.reader, TILDA)
            return popSingleCharToken(self.reader, CHAR_OUT_OF_RANGE)

        if c > ord('Z'):
            return popSingleCharToken(self.reader, INVALID_CHAR)
        if c >= ord('A'):
            return lexId(self.reader)
        if c > ord('9'):
            if c == ord('@'):
                return popSingleCharToken(self.reader, AT)
            else:
                return popSingleCharToken(self.reader, INVALID_CHAR)
        if c >= ord('0'):
            return lexNumber(self.reader)
        if c == ord('.'):
            return popSingleCharToken(self.reader, DOT)
        if c == ord('('):
            return popSingleCharToken(self.reader, LEFT_PAREN)
        if c == ord(')'):
            return popSingleCharToken(self.reader, RIGHT_PAREN)
        if c == ord(','):
            return popSingleCharToken(self.reader, COMMA)
        if c == ord('"'):
            return self.lexString()

        return popSingleCharToken(self.reader, INVALID_CHAR)

    # returns: 0 on EOF, otherwise, the next char
    def skipTrivial(self):
        while True:
            if self.reader.atEof():
                return False, 0 # EOF
            c = self.reader.peek()
            if c == ord(' ') or c == ord('\n'):
                self.reader.pop()
                continue
            if c == ord('#'):
                while True:
                    self.reader.pop()
                    if self.reader.atEof():
                        return False, 0 # EOF
                    c = self.reader.peek()
                    if c == ord('\n'):
                        break
                continue
            return True, c

    # reader points to open quote
    def lexString(self):
        start = self.reader.getPosition()
        chars = bytearray()
        while True:
            self.reader.pop()
            if self.reader.atEof():
                self.errAt(start, "quoted-string is missing close quote")
            c = self.reader.peek()
            if c == ord('\\'):
                escapePos = self.reader.getPosition()
                self.reader.pop()
                if self.reader.atEof():
                    self.errAt(escapePos, "unfinished escape sequence")
                e = self.reader.peek()
                if e == ord('n'):
                    chars.append(ord('\n'))
                else:
                    self.reader.pop()
                    self.errAt(escapePos, "invalid escape sequence \"{}\"".format(self.reader.str[escapePos:self.reader.getPosition()]))
            elif c == ord('"'):
                break
            else:
                chars.append(c)
        self.reader.pop()
        end = self.reader.getPosition()
        return StringToken(start, end, chars.decode('utf8'))

# assumption: reader is not at EOF
# returns: False on EOF
def scanWhile(reader, condition):
    while True:
        reader.pop()
        if reader.atEof():
            return False
        if not condition(reader.peek()):
            return True

def lexId(reader):
    start = reader.getPosition()
    scanWhile(reader, isIdChar)
    return Token(ID, start, reader.getPosition())

def lexNumber(reader):
    start = reader.getPosition()
    scanWhile(reader, isNumberChar)
    end = reader.getPosition()
    return NumberToken(start, end, int(reader.str[start:end]))


def isNonQuoteChar(c):
    return c != ord('"')

def isNumberChar(c):
    return (c >= ord('0')) and (c <= ord('9'))

def isIdChar(c):
    if c >= ord('a'):
        return c <= ord('z')
    if c >= ord('A'):
        return c <= ord('Z')
    if c >= ord('0'):
        return c <= ord('9')
    return c == '_'
