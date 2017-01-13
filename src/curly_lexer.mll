{

open Curly_parser

exception Error of string

}

rule token = parse
| [' ' '\t' '\r']
    { token lexbuf }
| '\n'
    { Lexing.new_line lexbuf; token lexbuf }
| '"'
    { read_string (Buffer.create 16) lexbuf }
| '''
    { read_single_quoted_string (Buffer.create 16) lexbuf }
| "//" [^ '\n']+ '\n'
    { Lexing.new_line lexbuf ; token lexbuf }
| "/*"
    { read_comment (Buffer.create 16) lexbuf }
| "#INACTIVE"
    { INACTIVE }
| "#EPHEMERAL"
    { EPHEMERAL }
| '{'
    { LEFT_BRACE }
| '}'
    { RIGHT_BRACE }
| '['
    { LEFT_BRACKET }
| ']'
    { RIGHT_BRACKET }
| ';'
    { SEMI }
| [^ ' ' '\t' '\n' '\r' '{' '}' '[' ']' ';' '#' '"' ''' ]+ as s
    { IDENTIFIER s}
| eof
    { EOF }
| _
{ raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }

and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | '\\' '\'' { Buffer.add_char buf '\''; read_string buf lexbuf }
  | '\\' '"' { Buffer.add_char buf '"'; read_string buf lexbuf }
  | '\n'      { Lexing.new_line lexbuf; Buffer.add_char buf '\n'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (Error (Printf.sprintf "Illegal string character: %s" (Lexing.lexeme lexbuf))) }
  | eof { raise (Error ("String is not terminated")) }

and read_single_quoted_string buf =
  parse
  | '''       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | '\\' '\'' { Buffer.add_char buf '\''; read_string buf lexbuf }
  | '\\' '"' { Buffer.add_char buf '"'; read_string buf lexbuf }
  | '\n'      { Lexing.new_line lexbuf; Buffer.add_char buf '\n'; read_string buf lexbuf }
  | [^ ''' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_single_quoted_string buf lexbuf
    }
  | _ { raise (Error (Printf.sprintf "Illegal string character: %s" (Lexing.lexeme lexbuf))) }
  | eof { raise (Error ("String is not terminated")) }

and read_comment buf =
  parse
  | "*/"
      { COMMENT (Buffer.contents buf) }
  | _
      { Buffer.add_string buf (Lexing.lexeme lexbuf);
        read_comment buf lexbuf
      }
