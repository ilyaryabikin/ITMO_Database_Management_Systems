CREATE OR REPLACE PROCEDURE
    inspect_schema(schema_name_in IN VARCHAR2)
    IS
    l_tables_count  NUMBER;
    l_columns_count VARCHAR2(2048);
    l_indexes_count VARCHAR2(2048);
    l_is_keyword    NUMBER;
    l_is_exists     NUMBER;
    l_is_permitted  NUMBER;
    l_t_name_pad    NUMBER := 30;
    l_t_columns_pad NUMBER := 10;
    l_t_rows_pad    NUMBER := 10;
BEGIN
    IF schema_name_in IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'Название схема не должно быть равно NULL');
    END IF;

    IF REGEXP_LIKE(schema_name_in, '^\s*$') THEN
        RAISE_APPLICATION_ERROR(-20000, 'Название схемы не должно быть пустой строкой');
    END IF;

    IF NOT REGEXP_LIKE(schema_name_in, '^[a-zA-Z_$#]+$') THEN
        RAISE_APPLICATION_ERROR(-20000, 'Название схемы не валидно');
    END IF;

    BEGIN
        SELECT 1 INTO l_is_keyword FROM V$RESERVED_WORDS WHERE schema_name_in = KEYWORD;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Название схемы не может быть зарезервированным словом базы данных');
    END;

    /*IF l_is_keyword = 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Название схемы не может быть зарезервированным словом базы данных');
    END IF;*/

    BEGIN
        SELECT 1 INTO l_is_exists FROM SYS.ALL_USERS WHERE UPPER(USERNAME) = UPPER(schema_name_in);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002, 'Введенная схема не существует');
    END;

    /*IF l_is_exists != 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Введенная схема не существует');
    END IF;*/

    BEGIN
        SELECT 1 INTO l_is_permitted FROM ALL_TABLES WHERE UPPER(OWNER) = UPPER(schema_name_in);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002, 'Введенная схема не существует');
    END;


    /*IF l_is_permitted != 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Вы не имеете доступа к введенной схеме');
    END IF;*/

    SELECT COUNT(TABLE_NAME)
    INTO l_tables_count
    FROM ALL_TABLES
    WHERE UPPER(OWNER) = UPPER(schema_name_in);
    SELECT COUNT(COLUMN_NAME)
    INTO l_columns_count
    FROM ALL_TAB_COLUMNS
    WHERE UPPER(OWNER) = UPPER(schema_name_in);
    SELECT COUNT(INDEX_NAME)
    INTO l_indexes_count
    FROM ALL_INDEXES
    WHERE UPPER(OWNER) = UPPER(schema_name_in);

    DBMS_OUTPUT.PUT_LINE('Количество таблиц в схеме ' || schema_name_in || ' - ' || l_tables_count);
    DBMS_OUTPUT.PUT_LINE('Количество столбцов в схеме ' || schema_name_in || ' - ' || l_columns_count);
    DBMS_OUTPUT.PUT_LINE('Количество индексов в схеме ' || schema_name_in || ' - ' || l_indexes_count);
    DBMS_OUTPUT.PUT_LINE('');

    DBMS_OUTPUT.PUT_LINE('Таблицы сехмы ' || schema_name_in);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT(RPAD('Имя', l_t_name_pad) || ' ');
    DBMS_OUTPUT.PUT(RPAD('Столбцов', l_t_columns_pad) || ' ');
    DBMS_OUTPUT.PUT(RPAD('Строк', l_t_rows_pad));
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');

    FOR cur_row IN (SELECT ALL_TABLES.TABLE_NAME              AS t_name,
                           COUNT(ALL_TAB_COLUMNS.COLUMN_NAME) AS t_columns,
                           ALL_TABLES.NUM_ROWS                AS t_rows
                    FROM ALL_TABLES
                             INNER JOIN ALL_TAB_COLUMNS ON ALL_TABLES.TABLE_NAME = ALL_TAB_COLUMNS.TABLE_NAME
                    WHERE UPPER(ALL_TABLES.OWNER) = UPPER(schema_name_in)
                      AND UPPER(ALL_TAB_COLUMNS.OWNER) = UPPER(schema_name_in)
                    GROUP BY ALL_TABLES.TABLE_NAME, ALL_TABLES.NUM_ROWS)
        LOOP
            DBMS_OUTPUT.PUT(RPAD(cur_row.t_name, l_t_name_pad) || ' ');
            DBMS_OUTPUT.PUT(RPAD(cur_row.t_columns, l_t_columns_pad) || ' ');
            DBMS_OUTPUT.PUT(RPAD(cur_row.t_rows, l_t_rows_pad));
            DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
END;
