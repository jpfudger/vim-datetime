

    "{{{ function: DATETIME_verify
    function! DATETIME_verify(date,year,month,day,hour,minute,second)
        let g:datetime = deepcopy(a:date)
        let result = 1
        if has_key(a:date, 'year')   && a:date.year   != a:year
            let result = 0
        endif
        if has_key(a:date, 'month')  && a:date.month  != a:month
            let result = 0
        endif
        if has_key(a:date, 'day')    && a:date.day    != a:day
            let result = 0
        endif
        if has_key(a:date, 'hour')   && a:date.hour   != a:hour
            let result = 0
        endif
        if has_key(a:date, 'minute') && a:date.minute != a:minute
            let result = 0
        endif
        if has_key(a:date, 'second') && a:date.second != a:second
            let result = 0
        endif
        call add(g:TEST_logs[-1],result)
    endfunction
    "}}}
    "{{{ function: DATETIME_validate
    function! DATETIME_validate(date)
        let result = 0
        if has_key( a:date, 'year' ) && a:date.year < 0
            let result = 0
        elseif has_key( a:date, 'month' ) && ( a:date.month < 1 || a:date.month > 12 )
            let result = 0
        elseif has_key( a:date, 'day' ) && ( a:date.day < 1 || a:date.day > 31 )
            let result = 0
        elseif has_key( a:date, 'hour' ) && ( a:date.hour < 0 || a:date.hour > 23 )
            let result = 0
        elseif has_key( a:date, 'minute' ) && ( a:date.minute < 0 || a:date.minute > 59 )
            let result = 0
        elseif has_key( a:date, 'second' ) && ( a:date.second < 0 || a:date.second > 59 )
            let result = 0
        else
            let result = 1
        endif
        call add(g:TEST_logs[-1],result)
    endfunction
    "}}}
    "{{{ function: TEST_verify
    function! TEST_verify( actual, expected )
        let result = a:actual == a:expected
        call add(g:TEST_logs[-1],result)
    endfunction
    "}}}

    "{{{ function: TEST_conclude
    function! TEST_conclude()
        if !exists("g:TEST_logs")
            let g:TEST_logs = []
        endif
        echo "Ran " . len(g:TEST_logs) . " tests:"
        let maxlen = max(map(copy(g:TEST_logs),'len(v:val[0])'))+1
        let failures = []
        for test in g:TEST_logs
            let xx = "  " . test[0] . repeat(" ",maxlen-len(test[0]))
                   \ . "  " . join(test[1:],",")
            if index(test,0) > 0
                call add(failures,test)
            endif
            echo xx
        endfor
        if empty(failures)
            echo "No failures"
        else
            echo "Failed " . len(failures) . " tests:"
            for test in failures
                echo test
            endfor
        endif
        unlet g:TEST_logs
    endfunction
    "}}}
    "{{{ function: TEST_log
    function! TEST_log(name)
        if !exists("g:TEST_logs")
            let g:TEST_logs = []
        endif
        call add(g:TEST_logs, [a:name])
    endfunction
    "}}}

    call TEST_log("strptime")
        let g:str = 'blah 26-Jan-2016 10:28:10 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify(g:dt1,2016,1,26,10,28,10)

    call TEST_log("to unixtime")
        let g:str = 'blah 27-Jan-2016 10:28:10 blah'
        let g:dt1 = datetime#strptime(g:str)
        call TEST_verify(datetime#unixtime(g:dt1), 1453890490)
        call TEST_verify(datetime#strftime(g:dt1,'%s'), '1453890490')

    call TEST_log("from unixtime")
        let g:str = 'blah 421030923 blah'
        let g:dt1 = datetime#strptime(g:str,'%s')
        call DATETIME_verify(g:dt1,1983,5,6,1,2,3)

    call TEST_log("month decode")
        let g:str = 'blah 28-Feb-2016 10:28:10 blah'
        let g:dt1 = datetime#strptime(g:str)
        call TEST_verify(datetime#strftime(g:dt1,'%B'), 'February')
        call TEST_verify(datetime#strftime(g:dt1,'%b'), 'Feb')

    call TEST_log("add day")
        let g:dt1 = datetime#init(2005,10,3,2,9,48)
        let g:dt2 = datetime#add_day(g:dt1,29)
        call DATETIME_verify(g:dt2,2005,11,1,2,9,48)

    call TEST_log("subtract day")
        let g:dt1 = datetime#init(2005,10,3,2,9,48)
        let g:dt2 = datetime#add_day(g:dt1,-4)
        call DATETIME_verify(g:dt2,2005,9,29,2,9,48)

    call TEST_log("add second")
        let g:dt1 = datetime#init(2005,10,3,2,9,48)
        let g:dt2 = datetime#add_second(g:dt1,3316)
        call DATETIME_verify(g:dt2,2005,10,3,3,5,4)

    call TEST_log("subtract second")
        let g:dt1 = datetime#init(2005,10,3,2,9,48)
        let g:dt2 = datetime#add_second(g:dt1,-22254)
        call DATETIME_verify(g:dt2,2005,10,2,19,58,54)

    call TEST_log("ordinal 1st")
        let g:dt1 = datetime#init(2005,10,1,2,9,48)
        let g:str = datetime#strftime(g:dt1,'%D')
        call TEST_verify(g:str,'1st')

    call TEST_log("ordinal 2nd")
        let g:dt1 = datetime#init(2005,10,2,2,9,48)
        let g:str = datetime#strftime(g:dt1,'%D')
        call TEST_verify(g:str,'2nd')

    call TEST_log("ordinal 3rd")
        let g:dt1 = datetime#init(2005,10,3,2,9,48)
        let g:str = datetime#strftime(g:dt1,'%D')
        call TEST_verify(g:str,'3rd')

    call TEST_log("ordinal 23rd")
        let g:dt1 = datetime#init(2005,10,23,2,9,48)
        let g:str = datetime#strftime(g:dt1,'%D')
        call TEST_verify(g:str,'23rd')

    call TEST_log("ordinal 31st")
        let g:dt1 = datetime#init(2005,10,31,2,9,48)
        let g:str = datetime#strftime(g:dt1,'%D')
        call TEST_verify(g:str,'31st')

    call TEST_log("month case upper long")
        let g:str = 'blah 12-JANUARY-2003 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 2003, 1, 12, 0, 0, 0 )

    call TEST_log("month case upper short")
        let g:str = 'blah 13-JAN-2003 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 2003, 1, 13, 0, 0, 0 )

    call TEST_log("month case lower long")
        let g:str = 'blah 14-january-2003 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 2003, 1, 14, 0, 0, 0 )

    call TEST_log("month case lower short")
        let g:str = 'blah 15-jan-2003 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 2003, 1, 15, 0, 0, 0 )

    call TEST_log("single digit day")
        let g:str = 'blah 1-DEC-2000 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 2000, 12, 1, 0, 0, 0 )

    call TEST_log("single digit month")
        let g:str = 'blah 1-1-1999 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 1999, 1, 1, 0, 0, 0 )

    call TEST_log("single digit month ^")
        let g:str = '1-1-1999 blah'
        let g:dt1 = datetime#strptime(g:str)
        call DATETIME_verify( g:dt1, 1999, 1, 1, 0, 0, 0 )

    call TEST_log("getftime")
        let g:str = expand("%:p")
        let g:dt1 = datetime#getftime(g:str)
        call DATETIME_validate(g:dt1)

    call TEST_conclude()
  
    " vim:tw=78:ts=8:ft=vim:fmr="{{{,"}}}:fdm=marker
