
    " Name:   datetime.vim
    " Author: Jonathan Fudger
    " Date:   17 May 2016
    " Shamelessly ported from the Python datetime package implementation
    " https://fossies.org/dox/Python-3.5.1/datetime_8py_source.html

    if exists('g:loaded_datetime') || &compatible
        finish
    endif
    let g:loaded_datetime = 1
    
    "{{{ function: s:init_datetime
    function! s:init_datetime(...)
        return { 'year'   : a:0 > 0 ? a:1 : 0,
               \ 'month'  : a:0 > 1 ? a:2 : 0,
               \ 'day'    : a:0 > 2 ? a:3 : 0,
               \ 'hour'   : a:0 > 3 ? a:4 : 0,
               \ 'minute' : a:0 > 4 ? a:5 : 0,
               \ 'second' : a:0 > 5 ? a:6 : 0,
               \ }
    endfunction
    "}}}
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
        " Constructs a full 6-key datetime.
        let date = s:init_datetime()
        if has_key(a:date,'year')   | let date.year   = a:date.year   | endif
        if has_key(a:date,'month')  | let date.month  = a:date.month  | endif
        if has_key(a:date,'day')    | let date.day    = a:date.day    | endif
        if has_key(a:date,'hour')   | let date.hour   = a:date.hour   | endif
        if has_key(a:date,'minute') | let date.minute = a:date.minute | endif
        if has_key(a:date,'second') | let date.second = a:date.second | endif
        return date
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
        let days_in_month = [-1,31,28,31,30,31,30,31,31,30,31,30,31]
        return days_in_month[a:month]
    endfunction
    "}}}
    "{{{ function: s:days_before_month
    function! s:days_before_month(month, year)
        " Returns the number of days in the year preceding first of month.
        let days_in_month = [-1,31,28,31,30,31,30,31,31,30,31,30,31]
        let days_before_month = [-1]
        let dbm = 0
        for dim in days_in_month[1:]
            call add(days_before_month,dbm)
            let dbm += dim
        endfor
        return days_before_month[a:month] + (a:month > 2 && s:is_leap(a:year))
    endfunction
    "}}}
    "{{{ function: s:day_of_year
    function! s:day_of_yr(date)
        return s:days_before_month(a:date.month,a:date.year) + a:date.day
    endfunction
    "}}}

    "{{{ function: s:date2ord
    function! s:date2ord(date)
        " Converts a datetime to a unique ordinal (days since 1,1,1).
        let dim = s:days_in_month(a:date.month, a:date.year)
        return s:days_before_year(a:date.year) 
               \ + s:days_before_month(a:date.month, a:date.year)
               \ + a:date.day
    endfunction
    "}}}
    "{{{ function: s:ord2date
    function! s:ord2date(ord)
        " Converts a unique ordinal (days since 1,1,1) to a datetime.
     
        let di400y = s:days_before_year(401) " no. of days in 400 years
        let di100y = s:days_before_year(101) " no. of days in 100 years
        let di4y   = s:days_before_year(5)   " no. of days in 4 years 

        let ord = a:ord - 1
        let ord400 = ord / di400y
        let ord = ord % di400y
        let year = ord400 * 400 + 1          " ..., -399, 1, 401, ...

        let ord100 = ord / di100y
        let ord = ord % di100y

        let ord4 = ord / di4y
        let ord = ord % di4y

        let ord1 = ord / 365
        let ord = ord % 365

        let year += ord100 * 100 + ord4 * 4 + ord1

        if ord1 == 4 || ord100 == 4
            return s:init_datetime( year - 1, 12 ,31 )
        endif

        let month = (ord + 50) / 32
        let preceding = s:days_before_month(month,year)

        if preceding > ord " estimate is too large
            let month -= 1
            let preceding -= s:days_in_month(month,year)
        endif

        let ord -= preceding

        return s:init_datetime( year, month, ord+1 )
            
    endfunction
    "}}}

    "{{{ function: s:rationalise
    function! s:rationalise(dt)
        let dt = copy(a:dt)

        " This function fixes a datetime object if the "seconds" field
        " is invalid (i.e. not in the range [0,59]).

        " It could be enhanced to fix invalid values in other fields.

        if dt.second > 59
            let dt.minute += dt.second / 60
            let dt.second  = dt.second % 60
            if dt.minute > 59
                let dt.hour += dt.minute / 60
                let dt.minute  = dt.minute % 60
                if dt.hour > 23
                    let inc_days  = dt.hour / 24
                    let dt.hour = dt.hour % 24
                    let date = s:add_day( dt, inc_days )
                    let dt.year = date.year
                    let dt.month = date.month
                    let dt.day = date.day
                endif
            endif
        endif
        
        if dt.second < 0
            let dt.minute -= ( 60 - dt.second ) / 60
            let dt.second  = 60 + dt.second % 60
            if dt.minute < 0
                let dt.hour -= ( 60 - dt.minute ) / 60
                let dt.minute  = 60 + dt.minute % 60
                if dt.hour < 0
                    let inc_days = ( 24 - dt.hour ) / 24
                    let dt.hour = 24 + dt.hour % 60
                    let date = s:add_day( dt, - inc_days )
                    let dt.year = date.year
                    let dt.month = date.month
                    let dt.day = date.day
                endif
            endif
        endif

        return dt
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
        let new_date.hour = a:date.hour
        let new_date.minute = a:date.minute
        let new_date.second = a:date.second
        return new_date
    endfunction
    "}}}
    "{{{ function: s:add_second
    function! s:add_second(date,inc)
        " Adds inc seconds to datetime.
        let dt = s:validate_date(a:date)
        let dt.second += a:inc
        return s:rationalise(dt)
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
        elseif a:tag ==# '%s'
            return '\d\+'
        elseif a:tag ==# '%f'
            return '\d\+'
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
        elseif a:tag ==# '%s'
            return str2nr(a:str)
        elseif a:tag ==# '%f'
            return str2nr(a:str)
        endif
    endfunction
    "}}}
    "{{{ function: s:decode_tagmap
    function! s:decode_tagmap(tag)
        " Returns the expected position of a tag in a datetime list.
        if a:tag ==# '%Y'
            return 'year'
        elseif a:tag ==# '%b'
            return 'month'
        elseif a:tag ==# '%B'
            return 'month'
        elseif a:tag ==# '%m'
            return 'month'
        elseif a:tag ==# '%d'
            return 'day'
        elseif a:tag ==# '%H'
            return 'hour'
        elseif a:tag ==# '%I'
            return 'hour'
        elseif a:tag ==# '%M'
            return 'minute'
        elseif a:tag ==# '%S'
            return 'second'
        elseif a:tag ==# '%s'
            return 'second'
        " elseif a:tag ==# '%f'
        "     return 'subsecond'
        endif
    endfunction
    "}}}
    "{{{ function: s:encode_element
    function! s:encode_element(date,tag)
        " Extracts an element of the datetime specified by the tag.
        if a:tag ==# '%y' && has_key(a:date,'year')
            return string(a:date.year)[2:3]
        elseif a:tag ==# '%Y' && has_key(a:date,'year')
            return string(a:date.year)
        elseif a:tag ==# '%p' && has_key(a:date,'year')
            let hr = a:date.hr == 12 ? 12 : a:date.hr % 12
            return hr > 12 ? 'PM' : 'AM'
        elseif a:tag ==# '%b' && has_key(a:date,'month')
            return s:month_name(a:date.month)
        elseif a:tag ==# '%B' && has_key(a:date,'month')
            return s:month_name(a:date.month,1)
        elseif a:tag ==# '%m' && has_key(a:date,'month')
            return s:pad(a:date.month,'00')
        elseif a:tag ==# '%d' && has_key(a:date,'day')
            return s:pad(a:date.day,'00')
        elseif a:tag ==# '%D' && has_key(a:date,'day')
            return s:ordinal_suffix(a:date.day)
        elseif a:tag ==# '%a' && has_key(a:date,'day')
            return s:day_of_date(a:date)
        elseif a:tag ==# '%A' && has_key(a:date,'day')
            return s:day_of_date(a:date,1)
        elseif a:tag ==# '%j' && has_key(a:date,'day')
            return s:pad(s:day_of_yr(a:date),'000')
        elseif a:tag ==# '%U' && has_key(a:date,'day')
            " Week number of year (Sunday as first day of week).
            let day_index = s:day_nr(s:day_of_date([a:date.year,1,1]))-1
            let day_of_yr = s:day_of_yr(a:date)
            return s:pad( (day_of_yr + day_index) / 7, '00')
        elseif a:tag ==# '%w' && has_key(a:date,'day')
            return s:date2ord(a:date) % 7
        elseif a:tag ==# '%W' && has_key(a:date,'day')
            " Week number of year (Monday as first day of week).
            let day_index = s:day_nr(s:day_of_date([a:date.year,1,1]))-2
            let day_of_yr = s:day_of_yr(a:date)
            return s:pad( (day_of_yr + day_index) / 7, '00')
        elseif a:tag ==# '%H' && has_key(a:date,'hour')
            return s:pad(a:date.hour,'00')
        elseif a:tag ==# '%I' && has_key(a:date,'hour')
            let hr = a:date.hour == 12 ? 12 : a:date.hour % 12
            return s:pad(hr,'00')
        elseif a:tag ==# '%M' && has_key(a:date,'minute')
            return s:pad(a:date.minute, '00')
        elseif a:tag ==# '%S' && has_key(a:date,'second')
            return s:pad(a:date.second, '00')
        elseif a:tag ==# '%s' && has_key(a:date,'second')
            return string(datetime#unixtime(a:date))
        " elseif a:tag ==# '%f' && has_key(a:date,'subsecond')
        "     return s:pad(a:date.subsecond, '000')
        endif
    endfunction
    "}}}

    "{{{ function: s:date_difference
    function! s:date_difference(d1,d2)
        " Returns a date difference in days. Time keys are ignored.
        let ord1 = s:date2ord(a:d1)
        let ord2 = s:date2ord(a:d2)
        return str2nr(ord2) - str2nr(ord1)
    endfunction
    "}}}
    "{{{ function: s:time_difference
    function! s:time_difference(dt1,dt2)
        " Returns a time difference in seconds. Date keys are ignored.
        let difference = 0
        let difference += (a:dt2.hour   - a:dt1.hour)   * 60 * 60
        let difference += (a:dt2.minute - a:dt1.minute) * 60
        let difference += (a:dt2.second - a:dt1.second)
        return difference
    endfunction
    "}}}

    "{{{ function: s:strptime_auto
    function! s:strptime_auto(str)
        " Tries to guess the some common date/time formats.
        let date = {}
        let time = {}
        let date_formats = [ '%d-%b-%Y',   '%d-%m-%Y', '%d-%B-%Y',
                           \ '%d/%m/%Y',
                           \ '%Y/d-%b-%Y', '%Y-%m-%d', '%Y-%b-%d',
                           \ ]

        let str = a:str

        " Convert all lower/uppers words to title case:
        let str = substitute( str, '\<\u\zs\(\u\+\)\>', '\L\1\E', 'g' )
        let str = substitute( str, '\<\(\l\)\ze\l\+\>', '\U\1\E', 'g' )

        " Prepend all single digits with 0:
        let str = substitute( str, '\D\zs\(\d\)\ze\D', '0\1', 'g' )
        let str = substitute( str, '\<\zs\(\d\)\ze\D', '0\1', 'g' )
        let str = substitute( str, '\D\zs\(\d\)\ze\>', '0\1', 'g' )

        let time_formats = [ '%H:%M:%S' ]
        for fmt in date_formats
            let date = s:strptime(str,fmt)
            if !empty(date) | break | endif
        endfor
        for fmt in time_formats
            let time = s:strptime(str,fmt)
            if !empty(time) | break | endif
        endfor
        if empty(date) && empty(time)
            return {}
        elseif empty(date)
            let date = s:init_datetime()
        elseif empty(time)
            let time = s:init_datetime()
        endif
        return s:init_datetime( date.year, date.month, date.day, 
                            \ time.hour, time.minute, time.second )
    endfunction
    "}}}
    "{{{ function: s:strptime
    function! s:strptime(str,fmt)
        " Converts a string to a datetime.
        let tags = 'YbBmdjHIMSs'
        let requested = []
        let fmt = substitute(a:fmt,'%%','__VIM__DUMMY__PERCENT__','g')
        let fmt = substitute(fmt,'\C%c','%x %X','g')
        let fmt = substitute(fmt,'\C%x','%d-%m-%Y','g')
        let fmt = substitute(fmt,'\C%X','%H:%M:%S','g')
        let tagmap = [] " maps from tag position in fmt to list position
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
            return {}
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

        let datetime = s:init_datetime()
        if index(requested,'%s') > -1
            " special case for converting from unix time
            if len(requested) == 1
                let unixtime = str2nr( matchstr( a:str, '\d\+' ) )
                let datetime = s:init_datetime(1970,1,1,0,0,unixtime)
                let datetime = s:rationalise(datetime)
            else
                echo "Unix time must be sole formatter"
                return {}
            endif
        else
            for xx in range(0,len(requested)-1)
                let decoded = s:decode_str2nr( requested[xx], matches[xx] ) 
                let tkey = s:decode_tagmap( requested[xx] )
                " echo requested[xx] ' ==> [' decoded '] ==> [' tkey ']'
                let datetime[tkey] = decoded
            endfor
        endif

        return datetime
    endfunction
    "}}}
    "{{{ function: s:strftime
    function! s:strftime(date,fmt)
        " Converts a datetime to a string.
        let fmt = a:fmt
        let fmt = substitute(fmt,'\C%c','%x %X','g')
        let fmt = substitute(fmt,'\C%x','%d-%m-%Y','g')
        let fmt = substitute(fmt,'\C%X','%H:%M:%S','g')
        let str = substitute(fmt,'%%','__VIM__DUMMY__PERCENT__','g')
        let tags = 'yYpbBmdDaAjUwWHIMSs'
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
        let dim = s:days_in_month( a:date.month, a:date.year )
        return [ s:init_datetime( a:date.year, a:date.month, 1 ), 
                 s:init_datetime( a:date.year, a:date.month, dim) ]
    endfunction
    "}}}
    "{{{ function: datetime#compare
    function! datetime#compare(dt1,dt2,...)
        " May be used to sort a list of dates
        let fmt = a:0 > 1 ? a:1 : ''

        let dt1 = type(a:dt1) == 1 ? datetime#strptime(a:dt1,fmt) : a:dt1
        let dt2 = type(a:dt2) == 1 ? datetime#strptime(a:dt2,fmt) : a:dt2

        let dt1 = s:validate_date(dt1)
        let dt2 = s:validate_date(dt2)

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
    function! datetime#delta(dt1,dt2)
        " Returns number of days and seconds between dt1 and dt2
        let dt1 = s:validate_date(a:dt1)
        let dt2 = s:validate_date(a:dt2)
        let date_diff = s:date_difference(dt1,dt2)
        let time_diff = s:time_difference(dt1,dt2)
        return [ date_diff, time_diff ]
    endfunction
    "}}}
    "{{{ function: datetime#unixtime
    function! datetime#unixtime(date)
        " Convert to number of seconds since [ 1970, 1, 1, 0, 0, 0 ]
        let epoch = s:init_datetime( 1970, 1, 1 )
        if datetime#compare(epoch,a:date) > 0
            return -1
        else
            let delta = datetime#delta(epoch,a:date)
            return ( delta[0] * 24 * 60 * 60 ) + delta[1]
        endif
    endfunction
    "}}}

    "{{{ function: datetime#init
    function! datetime#init(...)
        " Construct a datetime directly from a set of integers.
        return s:init_datetime(
                              \ a:0 > 0 ? a:1 : 0,
                              \ a:0 > 1 ? a:2 : 0,
                              \ a:0 > 2 ? a:3 : 0,
                              \ a:0 > 3 ? a:4 : 0,
                              \ a:0 > 4 ? a:5 : 0,
                              \ a:0 > 5 ? a:6 : 0,
                              \ )
    endfunction
    "}}}
    "{{{ function: datetime#strptime
    function! datetime#strptime(...)
        " Constructs a datetime from a string and a format.
        let str = a:0 > 0 ? a:1 : "."           " default to current line
        let fmt = a:0 > 1 ? a:2 : ""            " default to auto format
        if str == "." || str == "$" || type(str) == 0
            let str = getline(str)
        endif
        return empty(fmt) ? s:strptime_auto(str) : s:strptime(str,fmt)
    endfunction
    "}}}
    "{{{ function: datetime#strftime
    function! datetime#strftime(date,...)
        " Converts a datetime to a formatted string.
        if type(a:date) != 4
            echohl ErrorMsg
            echo "Expected a datetime dictionary."
            echohl NONE
            return ''
        endif
        let fmt = a:0 > 0 ? a:1 : '%c'
        return s:strftime(a:date,fmt)
    endfunction
    "}}}
    "{{{ function: datetime#reformat
    function! datetime#reformat(str,fmt1,fmt2)
        " Receives a string in fmt1; returns a string in fmt2.
        let str  = empty(a:str)  ? "."  : a:str   " default to current line  
        let fmt1 = empty(a:fmt1) ? "" : a:fmt1    " default to auto format
        let fmt2 = empty(a:fmt2) ? "%c" : a:fmt2  " default to %c
        let date = datetime#strptime(str,fmt1)
        return datetime#strftime(date,fmt2)
    endfunction
    "}}}

    " vim:tw=78:ts=8:ft=vim:fmr="{{{,"}}}:fdm=marker
