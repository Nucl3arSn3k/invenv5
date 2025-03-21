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