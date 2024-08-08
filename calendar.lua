#!/usr/bin/env lua

-- lua program to print the calendar


local weeks = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
}

local months = {
	"Janurary", 
	"February",
	"March",
	"April", 
	"May", 
	"June", 
	"July", 
	"August", 
	"September", 
	"October", 
	"November", 
	"December",
}


-- provides the first day (can be out of bounds) for that month or the
-- year. It calculates the relative date from the first day of that month.
local function getDayOffset(month, year)
	local day = os.date("*t", os.time{year=year, month=month, day=1})
	return 2 - day.wday
end

-- provides number of day in given month of year
local function daysInMonth(month, year)
	local days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	if year % 4 == 0 and month == 2
	then
		return 29
	end
	return days[month]
end

-- center text in given width
local function center(text, width)
	local diff = width - #text
	local pre = math.ceil(diff/2)
	local suf = math.floor(diff/2)
	return string.rep(" ", pre) .. text .. string.rep(" ", suf)
end

-- formats month name
local function formatMonthName(month)
	return center(months[month], 20)
end

-- formats month and year
local function formatMonthYear(month, year)
	local value = months[month] .. " " .. year
	return center(value, 20)
end

-- formats day, month and year
local function formatDayMonthYear(day, month, year)
	local value = months[month] .. " " .. day ", " .. year
	return center(value, 20)
end

-- format year
local function formatYear(year)
	return center(tostring(year), 72)
end

-- format week names
local function formatWeekNames()
	local value = ""
	for i, week in pairs(weeks)
	do
		if i ~= 1
		then
			value = value .. " "
		end
		value = value .. string.sub(week, 0, 2)
	end
	return value
end

-- format week days
local function formatWeekDays(offset, limit)
	local value = ""
	for i=1,7
	do
		if i ~= 1
		then
			value = value .. " "
		end

		if offset >= 1 and offset <= limit
		then
			value = value .. string.format("%2d", offset)
		else
			value = value .. "  "
		end

		offset = offset + 1
	end
	return value
end

-- print the calendar for whole year
function printYearCalendar(year)
	local weeks = formatWeekNames()

	local days = {}
	for month=1,12
	do
		days[month] = daysInMonth(month, year)
	end
	
	local offset = {}
	for month=1,12
	do
		offset[month] = getDayOffset(month, year)
	end

	print(formatYear(year))

	for i=1,4
	do
		local i = (i-1)*3

		print()
		io.write(formatMonthName(i+1))
		io.write(string.rep(" ", 6))
		io.write(formatMonthName(i+2))
		io.write(string.rep(" ", 6))
		io.write(formatMonthName(i+3))
		print()

		io.write(weeks)
		io.write(string.rep(" ", 6))
		io.write(weeks)
		io.write(string.rep(" ", 6))
		io.write(weeks)
		print()

		for j=1,6
		do
			local skip = 0
			for k=1,3
			do
				local month = i+k

				if k ~= 1
				then
					io.write(string.rep(" ", 6))
				end

				local off = offset[month]
				local limit = days[month]
				
				if off > limit
				then
					skip = skip + 1
				end

				io.write(formatWeekDays(off, limit))
				offset[month] = off + 7
			end

			if skip ~= 3
			then
				print()
			end
		end
	end
end

-- prinat calendar for given month of year
function printMonthCalendar(month, year)
	local day = getDayOffset(month, year)
	local days = daysInMonth(month, year)

	print(formatMonthYear(month, year))
	print(formatWeekNames())

	for _=1,7
	do
		io.write(formatWeekDays(day, days))
		print()
		day = day + 7

		if day > days
		then
			break
		end
	end
end

-- utility functions

local function isInteger(n)
	return string.match(n, "^[0-9]+$")
end

local function isYear(year)
	local int_year = tonumber(year)
	return isInteger(year) and int_year >= 1 and int_year <= 9999
end

local function isMonth(month)
	local int_month = tonumber(month)
	return isInteger(month) and int_month >= 1 and int_month <= 12
end

-- main entry function accepts year and month number
local function main(year, month)
	if year ~= nil and isYear(year) == false
	then
		print("Year must be a positive integer between 1-9999")
		return
	end

	if month ~= nil and isMonth(month) == false
	then
		print("Month must be a positive integer between 1-12")
		return
	end

	if year == nil and month == nil
	then
		date = os.date("*t")
		printYearCalendar(tonumber(date.year))
	elseif month == nil
	then
		printYearCalendar(tonumber(year))
	else
		printMonthCalendar(tonumber(month), tonumber(year))
	end
end


usage = [[
Usage: lua calendar.lua {[-h --help], [year]} [month]

Positional Arguments:
-h, --help				displays this message
year					year number [1-9999]
month					month number [1-12]
]]

args = {year=arg[1], month=arg[2], invalid=(arg[3] ~= nil)}

if args.invalid
then
	print("Invalid number of arguments")
	print(usage)
elseif args.year == "-h" or args.year == "--help"
then
	print(usage)
else
	main(args.year, args.month)
end
