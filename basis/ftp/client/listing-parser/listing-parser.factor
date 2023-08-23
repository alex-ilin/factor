! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators io.files.types kernel math.parser
sequences splitting ;
IN: ftp.client.listing-parser

: ch>file-type ( ch -- type )
    {
        { CHAR: b [ +block-device+ ] }
        { CHAR: c [ +character-device+ ] }
        { CHAR: d [ +directory+ ] }
        { CHAR: l [ +symbolic-link+ ] }
        { CHAR: s [ +socket+ ] }
        { CHAR: p [ +fifo+ ] }
        { CHAR: - [ +regular-file+ ] }
        [ drop +unknown+ ]
    } case ;

: file-type>ch ( type -- string )
    {
        { +block-device+ [ CHAR: b ] }
        { +character-device+ [ CHAR: c ] }
        { +directory+ [ CHAR: d ] }
        { +symbolic-link+ [ CHAR: l ] }
        { +socket+ [ CHAR: s ] }
        { +fifo+ [ CHAR: p ] }
        { +regular-file+ [ CHAR: - ] }
        [ drop CHAR: - ]
    } case ;

: parse-permissions ( remote-file str -- remote-file )
    [ first ch>file-type >>type ] [ rest >>permissions ] bi ;

TUPLE: remote-file
type permissions links owner group size month day time year
name target ;

: <remote-file> ( -- remote-file ) remote-file new ;

: parse-list-11 ( lines -- seq )
    [
        11 f pad-tail
        <remote-file> swap {
            [ 0 idx parse-permissions ]
            [ 1 idx string>number >>links ]
            [ 2 idx >>owner ]
            [ 3 idx >>group ]
            [ 4 idx string>number >>size ]
            [ 5 idx >>month ]
            [ 6 idx >>day ]
            [ 7 idx >>time ]
            [ 8 idx >>name ]
            [ 10 idx >>target ]
        } cleave
    ] map ;

: parse-list-8 ( lines -- seq )
    [
        <remote-file> swap {
            [ 0 idx parse-permissions ]
            [ 1 idx string>number >>links ]
            [ 2 idx >>owner ]
            [ 3 idx >>size ]
            [ 4 idx >>month ]
            [ 5 idx >>day ]
            [ 6 idx >>time ]
            [ 7 idx >>name ]
        } cleave
    ] map ;

: parse-list-3 ( lines -- seq )
    [
        <remote-file> swap {
            [ 0 idx parse-permissions ]
            [ 1 idx string>number >>links ]
            [ 2 idx >>name ]
        } cleave
    ] map ;

: parse-list ( ftp-response -- ftp-response )
    dup strings>>
    [ split-words harvest ] map
    dup length {
        { 11 [ parse-list-11 ] }
        { 9 [ parse-list-11 ] }
        { 8 [ parse-list-8 ] }
        { 3 [ parse-list-3 ] }
        [ drop ]
    } case >>parsed ;
