
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SQLITE-FUNCTIONS.

       ENVIRONMENT DIVISION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-DB-HANDLE           POINTER.
       01 WS-ERR-MSG             POINTER.
       01 WS-RESULT-CODE         PIC 9(4) COMP-5.
       01 WS-CALLBACK            PROCEDURE-POINTER.
       01 WS-SQL-BUFFER          PIC X(1024).
       01 WS-TEMP-ID             PIC 9(4).
       01 WS-TEMP-NAME           PIC X(50).
       
       LINKAGE SECTION.
       01 LNK-DB-NAME            PIC X(255).
       01 LNK-RECORD-ID          PIC 9(4).
       01 LNK-RECORD-NAME        PIC X(50).
       01 LNK-SQL-STATEMENT      PIC X(1024).
       01 LNK-STATUS             PIC 9.
           88 LNK-SUCCESS        VALUE 0.
           88 LNK-ERROR          VALUE 1.
           
       PROCEDURE DIVISION.
           GOBACK.
           
      *----------------------------------------------------------------*
      * OPEN-DATABASE: Opens a connection to an SQLite database        *
      *----------------------------------------------------------------*
           ENTRY 'OPEN-DATABASE' USING 
           LNK-DB-NAME
           LNK-STATUS.
           
           SET WS-DB-HANDLE TO NULL
           SET WS-ERR-MSG TO NULL
           
           DISPLAY "Opening database: " LNK-DB-NAME
           
           CALL "sqlite3_open" USING
               BY REFERENCE LNK-DB-NAME
               BY REFERENCE WS-DB-HANDLE
               RETURNING WS-RESULT-CODE
           END-CALL
           
           IF WS-RESULT-CODE = ZERO
               MOVE 0 TO LNK-STATUS
               DISPLAY "Database opened successfully"
           ELSE
               MOVE 1 TO LNK-STATUS
               DISPLAY "Error opening database: " WS-RESULT-CODE
           END-IF
           
           GOBACK.
           
      *----------------------------------------------------------------*
      * CLOSE-DATABASE: Closes the current database connection         *
      *----------------------------------------------------------------*
           ENTRY 'CLOSE-DATABASE' USING
           LNK-STATUS.
           
           IF WS-DB-HANDLE = NULL
               DISPLAY "No database connection to close"
               MOVE 1 TO LNK-STATUS
               GOBACK
           END-IF
           
           CALL "sqlite3_close" USING
               BY REFERENCE WS-DB-HANDLE
               RETURNING WS-RESULT-CODE
           END-CALL
           
           IF WS-RESULT-CODE = ZERO
               MOVE 0 TO LNK-STATUS
               DISPLAY "Database closed successfully"
           ELSE
               MOVE 1 TO LNK-STATUS
               DISPLAY "Error closing database: " WS-RESULT-CODE
           END-IF
           
           SET WS-DB-HANDLE TO NULL
           
           GOBACK.