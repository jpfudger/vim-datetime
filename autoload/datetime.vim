
    " Name:   datetime.vim
    " Author: Jonathan Fudger
    " Date:   17 May 2016
    " Ported from the Python datetime package implementation
    " https://fossies.org/dox/Python-3.5.1/datetime_8py_source.html

    let g:loaded_datetime = 1

    "{{{ function: s:pad
    function! s:pad(nr,padding)
        " Converts an int to a char-padded string.
        let char = a:padding[0]
        let length = len(a:padding)
        let nr_len = len(string(a:nr))
        return repeat(char,(length-nr_len)) . string(a:nr)
    endfunction
    "}}}
    "{{{ function: s:validate_date
    function! s:validate_date(date)
        " Constructs a 6-element datetime.
        let date = a:date
        if type(date) == 1 " If it's a string - try and convert it.
            return s:strptime_auto(date)
        elseif len(date) == 1
            return [ date[0], 0, 0, 0, 0, 0 ]
        elseif len(date) == 2
            return [ date[0], date[1], 0, 0, 0, 0 ]
        elseif len(date) == 3
            return [ date[0], date[1], date[2], 0, 0, 0 ]
        elseif len(date) == 4
            return [ date[0], date[1], date[2], date[3], 0, 0 ]
        elseif len(date) == 5
            return [ date[0], date[1], date[2], date[3], date[4], 0 ]
        elseif len(date) == 6
            return [ date[0], date[1], date[2], date[3], date[4], date[5] ]
        else
            return [ 0, 0, 0, 0, 0, 0 ]
        endif
    endfunction
    "}}}
    "{{{ function: s:ordinal_suffix
    function! s:ordinal_suffix(nr)
        " Formats an int with its ordinal suffix.
        let mod100 = a:nr % 100
        let mod10  = a:nr % 10
        if 4 <= mod100 && mod100 <= 20
            return string(a:nr) . 'th'
        elseif mod10 == 1
            return string(a:nr) . 'st'
        elseif mod10 == 2
            return string(a:nr) . 'nd'
        elseif mod10 == 3
            return string(a:nr) . 'rd'
        else
            return string(a:nr) . 'th'
        endif
    endfunction
    "}}}

    "{{{ function: s:day_nr
    function! s:day_nr(day)
        " Converts a day name to a number [1,7].
        let names = [ "mon", "tue", "wed", "thu", "fri", "sat", "sun" ]
        return index(names,tolower(a:day[0:2])) + 1 
    endfunction
    "}}}
    "{{{ function: s:day_name
    function! s:day_name(nr,...)
        " Converts a day number [1-7] to its name.
        let long = a:0 > 0 ? a:1 : 0
        let names = [ "", "Monday", "Tuesday", "Wednesday", 
                    \ "Thursday", "Friday", "Sat", "Sunday" ]
        return long ? names[a:nr] : names[a:nr][0:2]
    endfunction
    "}}}
    "{{{ function: s:month_nr
    function! s:month_nr(month)
        " Converts a month name to a number [1,12].
        let names = [ "jan", "feb", "mar", "apr", "may", "jun",
                    \ "jul", "aug", "sep", "oct", "nov", "dec" ]
        return index(names,tolower(a:month[0:2])) + 1
    endfunction
    "}}}
    "{{{ function: s:month_name
    function! s:month_name(nr,...)
        " Converts a month number [1-12] to its name.
        let long = a:0 > 0 ? a:1 : 0
        let names = [ "", "January", "February", "March", "April", 
                    \ "May", "June", "July", "August", "September", 
                    \ "October", "November", "December" ]
        return long ? names[a:nr] : names[a:nr][0:2]
    endfunction
    "}}}

    "{{{ function: s:is_leap
    function! s:is_leap(year)
        return a:year % 4 == 0 && ( a:year % 100 != 0 || a:year % 400 == 0 )
    endfunction
    "}}}
    "{{{ function: s:days_before_year
    function! s:days_before_year(year)
        " Returns the number of days before January 1st of year.
        let yy = a:year - 1
        return yy*365 + yy/4 - yy/100 + yy/400
    endfunction
    "}}}
    "{{{ function: s:days_in_month
    function! s:days_in_month(month,year)
        " Returns the number of days in the month of the year.
        if a:month == 2 && s:is_leap(a:year) | return 29 | endif
        let days_in_month = [-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return days_in_month[a:month]
    endfunction
    "}}}
    "{{{ function: s:days_before_month
    function! s:days_before_month(month, year)
        " Returns the number of days in the year preceding first of the month.
        let days_in_month = [-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let days_before_month = [-1]
        let dbm = 0
        for dim in days_in_month[1:]
            call add(days_before_month,dbm)
            let dbm += dim
        endfor
        return days_before_month[a:month] + (a:month > 2 && s:is_leap(a:year))
    endfunction
    "}}}

    "{{{ function: s:date2ord
    function! s:date2ord(date)
        " Converts a date to an ordinal, considering [1,1,1] as day 1.
        let dim = s:days_in_month(a:date[1], a:date[0])
        return s:days_before_year(a:date[0]) 
               \ + s:days_before_month(a:date[1], a:date[0])
               \ + a:date[2]
    endfunction
    "}}}
    "{{{ function: s:ord2date
    function! s:ord2date(ord)
        " Converts an ordinal to a date, considering [1,1,1] as day 1.
     
        let di400y = s:days_before_year(401)   " number of days in 400 years
        let di100y = s:days_before_year(101)   " number of days in 100 years
        let di4y   = s:days_before_year(5)     " number of days in 4 years 

        let ord = a:ord - 1
        let ord400 = ord / di400y
        let ord = ord % di400y
        let year = ord400 * 400 + 1        " ..., -399, 1, 401, ...

        let ord100 = ord / di100y
        let ord = ord % di100y

        let ord4 = ord / di4y
        let ord = ord % di4y

        let ord1 = ord / 365
        let ord = ord % 365

        let year += ord100 * 100 + ord4 * 4 + ord1

        if ord1 == 4 || ord100 == 4
            return [ year - 1, 12 ,31 ]
        endif

        let month = (ord + 50) / 32
        let preceding = s:days_before_month(month,year)

        if preceding > ord " estimate is too large
            let month -= 1
            let preceding -= s:days_in_month(month,year)
        endif

        let ord -= preceding

        return [ year, month, ord+1 ]
            
    endfunction
    "}}}

    "{{{ function: s:day_of_date
    function! s:day_of_date(date,...)
        " Given a datetime, returns its day name.
        let long = a:0 > 0 ? a:1 : 0
        let ord = s:date2ord(a:date)
        return s:day_name(ord % 7, long)
    endfunction
    "}}}
    "{{{ function: s:add_day
    function! s:add_day(date,inc)
        " Adds inc days to the date. Time is preserved.
        let ord = s:date2ord(a:date)
        let ord += a:inc
        let new_date = s:ord2date(ord)
        if len(a:date) == 6
            let new_date += [ a:date[3], a:date[4], a:date[5] ]
        endif
        return new_date
    endfunction
    "}}}
    "{{{ function: s:add_second
    function! s:add_second(date,inc)
        " Adds inc seconds to datetime.
        let dt = s:validate_date(a:date)
        let new_dt = copy(dt)
        let new_dt[5] += a:inc

        " echo new_dt

        if new_dt[5] > 59
            let new_dt[4] += new_dt[5] / 60
            let new_dt[5]  = new_dt[5] % 60
            if new_dt[4] > 59
                let new_dt[3] += new_dt[4] / 60
                let new_dt[4]  = new_dt[4] % 60
                if new_dt[3] > 23
                    let inc_days  = new_dt[3] / 24
                    let new_dt[3] = new_dt[3] % 24
                    let date = s:add_day( dt[0:2], inc_days )
                    let new_dt[0] = date[0]
                    let new_dt[1] = date[1]
                    let new_dt[2] = date[2]
                endif
            endif
        endif
        
        if new_dt[5] < 0
            let new_dt[4] -= ( 60 - new_dt[5] ) / 60
            let new_dt[5]  = 60 + new_dt[5] % 60
            if new_dt[4] < 0
                let new_dt[3] -= ( 60 - new_dt[4] ) / 60
                let new_dt[4]  = 60 + new_dt[4] % 60
                if new_dt[3] < 0
                    let inc_days = ( 24 - new_dt[3] ) / 24
                    let new_dt[3] = 24 + new_dt[3] % 60
                    let date = s:add_day( dt[0:2], - inc_days )
                    let new_dt[0] = date[0]
                    let new_dt[1] = date[1]
                    let new_dt[2] = date[2]
                endif
            endif
        endif

        return new_dt
    endfunction
    "}}}

    "{{{ function: s:regex_of_tag
    function! s:regex_of_tag(tag)
        " Returns the regex pattern for the tag.
        if a:tag ==# '%Y'
            return '\d\d\d\d'
        elseif a:tag ==# '%b'
            return '\u\l\l'
        elseif a:tag ==# '%B'
            return '\u\l\l\+'
        elseif a:tag ==# '%m'
            return '\d\d'
        elseif a:tag ==# '%d'
            return '\d\d'
        elseif a:tag ==# '%H'
            return '\d\d'
        elseif a:tag ==# '%I'
            return '\d\d'
        elseif a:tag ==# '%M'
            return '\d\d'
        elseif a:tag ==# '%S'
            return '\d\d'
        endif
    endfunction
    "}}}
    "{{{ function: s:decode_str2nr
    function! s:decode_str2nr(tag,str)
        " Converts the decoded string to an int.
        if a:tag ==# '%Y'
            return str2nr(a:str)
        elseif a:tag ==# '%b'
            return s:month_nr( a:str )
        elseif a:tag ==# '%B'
            return s:month_nr( a:str )
        elseif a:tag ==# '%m'
            return str2nr(a:str)
        elseif a:tag ==# '%d'
            return str2nr(a:str)
        elseif a:tag ==# '%H'
            return str2nr(a:str)
        elseif a:tag ==# '%I'
            return str2nr(a:str)
        elseif a:tag ==# '%M'
            return str2nr(a:str)
        elseif a:tag ==# '%S'
            return str2nr(a:str)
        endif
    endfunction
    "}}}
    "{{{ function: s:decode_tagmap
    function! s:decode_tagmap(tag)
        " Returns the expected position of a tag in a datetime list.
        if a:tag ==# '%Y'
            return 0
        elseif a:tag ==# '%b'
            return 1
        elseif a:tag ==# '%B'
            return 1
        elseif a:tag ==# '%m'
            return 1
        elseif a:tag ==# '%d'
            return 2
        elseif a:tag ==# '%H'
            return 3
        elseif a:tag ==# '%I'
            return 3
        elseif a:tag ==# '%M'
            return 4
        elseif a:tag ==# '%S'
            return 5
        endif
    endfunction
    "}}}
    "{{{ function: s:encode_element
    function! s:encode_element(date,tag)
        " Extracts an element of the datetime specified by the tag.
        if len(a:date) == 0 | return '' | endif
        if a:tag ==# '%y'
            return string(a:date[0])[2:3]
        endif
        if a:tag ==# '%Y'
            return string(a:date[0])
        endif
        if a:tag ==# '%p'
            let hr = a:date[0] == 12 ? 12 : a:date[0] % 12
            return a:date[0] > 12 ? 'PM' : 'AM'
        endif
        if len(a:date) == 1 | return '' | endif
        if a:tag ==# '%b'
            return s:month_name(a:date[1])
        endif
        if a:tag ==# '%B'
            return s:month_name(a:date[1],1)
        endif
        if a:tag ==# '%m'
            return s:pad(a:date[1],'00')
        endif
        if len(a:date) == 2 | return '' | endif
        if a:tag ==# '%d'
            return s:pad(a:date[2],'00')
        endif
        if a:tag ==# '%a'
            return s:day_of_date(a:date)
        endif
        if a:tag ==# '%A'
            return s:day_of_date(a:date,1)
        endif
        if a:tag ==# '%j'
            let day_of_yr = s:days_before_month(a:date[1],a:date[0]) + a:date[2]
            return s:pad(day_of_yr,'000')
        endif
        if a:tag ==# '%U'
            " Week number of year (Sunday as first day of week).
            let day_of_yr = s:days_before_month(a:date[1],a:date[0]) + a:date[2]
            return s:pad( day_of_yr / 7, '00')
        endif
        if a:tag ==# '%w'
            return s:date2ord(a:date) % 7
        endif
        if a:tag ==# '%W'
            " Week number of year (Monday as first day of week).
            let day_of_yr = s:days_before_month(a:date[1],a:date[0]) + a:date[2]
            return s:pad( day_of_yr % 7, '00')
        endif
        if len(a:date) == 3 | return '' | endif
        if a:tag ==# '%H'
            return s:pad(a:date[3],'00')
        endif
        if a:tag ==# '%I'
            let hr = a:date[3] == 12 ? 12 : a:date[3] % 12
            return s:pad(hr,'00')
        endif
        if len(a:date) == 4 | return '' | endif
        if a:tag ==# '%M'
            return s:pad(a:date[4], '00')
        endif
        if len(a:date) == 5 | return '' | endif
        if a:tag ==# '%S'
            return s:pad(a:date[5], '00')
        endif
    endfunction
    "}}}

    "{{{ function: s:date_difference
    function! s:date_difference(d1,d2)
        " Returns a date difference in days.
        let ord1 = s:date2ord(a:d1)
        let ord2 = s:date2ord(a:d2)
        return str2nr(ord2) - str2nr(ord1)
    endfunction
    "}}}
    "{{{ function: s:time_difference
    function! s:time_difference(t1,t2)
        " Returns a time difference in seconds.
        let difference = 0
        let difference += (a:t2[0] - a:t1[0]) * 60 * 60
        let difference += (a:t2[1] - a:t1[1]) * 60
        let difference += (a:t2[2] - a:t1[2])
        return difference
    endfunction
    "}}}

    "{{{ function: s:strptime_auto
    function! s:strptime_auto(str)
        " Tries to guess the some common date/time formats.
        let date = []
        let time = []
        let date_formats = [ '%d-%b-%Y',   '%d-%m-%Y', '%d-%B-%Y',
                           \ '%d/%m/%Y',   '%d/%m/%Y',
                           \ '%Y/d-%b-%Y', '%Y-%m-%d', '%Y-%b-%d',
                           \ ]
        let time_formats = [ '%H:%M:%S' ]
        for fmt in date_formats
            let date = s:strptime(a:str,fmt)
            if !empty(date) | break | endif
        endfor
        for fmt in time_formats
            let time = s:strptime(a:str,fmt)
            if !empty(time) | break | endif
        endfor
        if empty(date) && empty(time)
            return []
        elseif empty(date)
            let date = [0,0,0,0,0,0]
        elseif empty(time)
            let time = [0,0,0,0,0,0]
        endif
        return [ date[0], date[1], date[2], time[3], time[4], time[5] ]
    endfunction
    "}}}
    "{{{ function: s:strptime
    function! s:strptime(str,fmt)
        " Converts a string to a datetime.
        let tags = 'YbBmdjHIMS'
        let requested = []
        let fmt = substitute(a:fmt,'%%','__VIM__DUMMY__PERCENT__','g')
        let fmt = substitute(fmt,'\C%c','%a %b %d %Y','g')
        let fmt = substitute(fmt,'\C%x','%d/%m/%Y','g')
        let fmt = substitute(fmt,'\C%X','%H:%M:%S','g')
        let tagmap = [] " maps from tag position in fmt to list position
        " echo fmt
        for xtag in map(split(tags,'\.*'),'"%".v:val')
            if fmt =~# xtag
                let regex = s:regex_of_tag(xtag)
                call add(tagmap,match(fmt,'\C'.xtag))
                call add(requested,xtag)
                let regex = escape( '\(' . regex . '\)', '\' )
                let fmt = substitute(fmt, '\C'.xtag, regex, 'g')
            endif
        endfor
        let fmt = substitute(fmt,'__VIM__DUMMY__PERCENT__','%','g')
        let matches = matchlist( a:str, fmt )

        if empty(matches) || empty(matches[0])
            return []
        endif

        let matches = matches[1:len(requested)]

        " need put the requests in the order they appear in the fmt
        let ordered = repeat([-1],len(tagmap))
        let xx = 0
        while xx < len(tagmap)
            let cmin = min(tagmap)
            let cmindex = index(tagmap,cmin)
            let tagmap[cmindex] = 9999999
            let ordered[cmindex] = requested[xx]
            let xx += 1
        endwhile
        let requested = ordered

        let datetime = [ 0, 0, 0, 0, 0, 0 ]
        for xx in range(0,len(requested)-1)
            let decoded = s:decode_str2nr( requested[xx], matches[xx] ) 
            let tmap = s:decode_tagmap( requested[xx] )
            " echo requested[xx] ' ==> [' decoded '] ==> [' tmap ']'
            let datetime[tmap] = decoded
        endfor

        if datetime[-1] == 0 && datetime[-2] == 0 && datetime[-3] == 0
            let datetime = datetime[0:2]
        endif

        return datetime
    endfunction
    "}}}
    "{{{ function: s:strftime
    function! s:strftime(date,fmt)
        " Converts a datetime to a string.
        let fmt = a:fmt
        if len(a:date) == 3
            let fmt = substitute(fmt,'\C%c','%a %b %d %Y','g')
            let fmt = substitute(fmt,'\C%x','%d/%m/%Y','g')
            let fmt = substitute(fmt,'\C%X','','g')
        elseif len(a:date) == 6
            let fmt = substitute(fmt,'\C%c','%a %b %d %H:%M:%S %Y','g')
            let fmt = substitute(fmt,'\C%x','%d/%m/%Y','g')
            let fmt = substitute(fmt,'\C%X','%H:%M:%S','g')
        endif
        let str = substitute(fmt,'%%','__VIM__DUMMY__PERCENT__','g')
        let tags = 'yYpbBmdaAjUwWHIMS'
        for xtag in map(split(tags,'\.*'),'"%".v:val')
            if str =~# xtag
                let enc = s:encode_element(a:date,xtag)
                let str = substitute(str,'\C'.xtag,enc,'g')
            endif
        endfor
        let str = substitute(str,'__VIM__DUMMY__PERCENT__','%','g')
        return str
    endfunction
    "}}}

    "{{{ function: datetime#now
    function! datetime#now()
        " Returns a 6-element datetime from native strftime
        let str = strftime("%Y %b %d %X")
        return s:strptime(str,"%Y %b %d %X")
    endfunction
    "}}}
    "{{{ function: datetime#add_day
    function! datetime#add_day(date,...)
        " Adds or subtracts a number of days onto a datetime.
        let inc = a:0 > 0 ? a:1 : 1
        return s:add_day(a:date,inc)
    endfunction
    "}}}
    "{{{ function: datetime#add_second
    function! datetime#add_second(date,...)
        " Adds or subtracts a number of seconds onto a datetime.
        let inc = a:0 > 0 ? a:1 : 1
        return s:add_second(a:date,inc)
    endfunction
    "}}}
    "{{{ function: datetime#week_range
    function! datetime#week_range( date )
        " Returns the Monday-Friday date range of the datetime
        let day = s:day_of_date(a:date)
        let delta1 = -index( ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], day)
        let delta2 =  index( ["Fri","Thu","Wed","Tue","Mon","Sun","Sat"], day)
        let last_monday = s:add_day(a:date, delta1)
        let next_friday = s:add_day(a:date, delta2)
        return [ last_monday, next_friday ]
    endfunction
    "}}}
    "{{{ function: datetime#month_range
    function! datetime#month_range( date )
        " Returns the month range (1st-nth day) of the datetime
        let dim = s:days_in_month( a:date[1], a:date[0] )
        return [ [ a:date[0], a:date[1], 1 ], [ a:date[0], a:date[1], dim ] ]
    endfunction
    "}}}
    "{{{ function: datetime#compare
    function! datetime#compare(dt1,dt2)
        " May be used to sort a list of dates
        let dt1 = s:validate_date(a:dt1)
        let dt2 = s:validate_date(a:dt2)

        let d_nr1 = str2nr(s:strftime(dt1,"%Y%m%d%H%M%S"))
        let d_nr2 = str2nr(s:strftime(dt2,"%Y%m%d%H%M%S"))
        let t_nr1 = str2nr(s:strftime(dt1,"%H%M%S"))
        let t_nr2 = str2nr(s:strftime(dt2,"%H%M%S"))

        if d_nr1 == d_nr2
            return t_nr1 == t_nr2 ? 0 : t_nr1 > t_nr1 ? 1 : -1
        else
            return d_nr1 > d_nr2 ? 1 : -1
        endif
    endfunction
    "}}}
    "{{{ function: datetime#delta
    function! datetime#delta(d1,d2)
        " Returns number of days between d1 and d2
        let d1 = s:validate_date(a:d1)
        let d2 = s:validate_date(a:d2)
        let date_diff = s:date_difference(d1[0:2],d2[0:2])
        let time_diff = s:time_difference(d1[3:5],d2[3:5])
        return [ date_diff, time_diff ]
    endfunction
    "}}}
    "{{{ function: datetime#unixtime
    function! datetime#unixtime(date)
        " Convert to number of seconds since [ 1970, 1, 1, 0, 0, 0 ]
        let epoch = [ 1970, 1, 1, 0, 0, 0 ]
        if datetime#compare(epoch,a:date) > 0
            return -1
        else
            let delta = datetime#delta(epoch,a:date)
            return ( delta[0] * 24 * 60 * 60 ) + delta[1]
        endif
    endfunction
    "}}}

    "{{{ function: datetime#strptime
    function! datetime#strptime(...)
        " Converts a string to a datetime.
        " Defaults to guessing the format of the current line.
        let str = a:0 > 0 ? a:1 : "."
        let fmt = a:0 > 1 ? a:2 : ""
        if str == "." || str == "$" || type(str) == 0
            let str = getline(str)
        endif
        return empty(fmt) ? s:strptime_auto(str) : s:strptime(str,fmt)
    endfunction
    "}}}
    "{{{ function: datetime#strftime
    function! datetime#strftime(date,...)
        " Converts a datetime to a formatted string.
        let fmt = a:0 > 0 ? a:1 : '%c'
        return s:strftime(a:date,fmt)
    endfunction
    "}}}
    "{{{ function: datetime#reformat
    function! datetime#reformat(str,fmt1,fmt2)
        " Receives a string in fmt1, returns a string in fmt2.
        let str  = empty(a:str)  ? "."  : a:str
        let fmt1 = empty(a:fmt1) ? "%c" : a:fmt1
        let fmt2 = empty(a:fmt2) ? "%c" : a:fmt2
        let date = datetime#strptime(str,fmt1)
        return datetime#strftime(date,fmt2)
    endfunction
    "}}}

    " vim:tw=78:ts=8:ft=vim:fmr="{{{,"}}}:fdm=marker
