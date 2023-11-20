# Night shift interval
$NIGHT_SHIFT = 22
$END_NS = 6

# Day types
$NORM_D = 0
$REST_D = 1
$SNWD = 2
$SNWD_RD = 3
$RH_D = 4
$RH_REST = 5

$VALID_DAY_RANGE = 1..8 # 7 days + exit option
$VALID_DAY_TYPE_RANGE = 0..5
$VALID_TIME_RANGE = 0..2400


def getHourDiff(in_hour, out_hour)
    (((out_hour - in_hour) % 24) + 24) % 24
end


def weeklyReport
    $payrolls.each do |payroll|
        printDayPayroll(payroll)
    end
end


def dayReport
    printChoices($days)
    choice = getValidRange("Enter the Day of the Payroll to display: ", $VALID_DAY_RANGE)

    selectedDayroll = $payrolls[choice-1]

    printDayPayroll(selectedDayroll)

    selectedDayroll
end


def editTime(time)
    in_or_out = time == 0 ? "IN" : "OUT"

    if time == 0
        prompt = "Editing the IN time will affect the OUT time to match each other. Do you wish to proceed? (y/n)"
        y_or_n = getValidDecision(prompt) == 'y' ? 1 : 0
        if y_or_n == 0
            return
        end
    end

    printChoices($days)
    choice = getValidRange("Enter the Day of the #{in_or_out} time to edit: ", $VALID_DAY_RANGE)
    payrollToEdit = $payrolls[choice-1]

    printDayPayroll(payrollToEdit)

    new_time = getValidTime(in_or_out, payrollToEdit.in_time, $VALID_TIME_RANGE)

    if time == 0
        payrollToEdit.in_time = new_time
        payrollToEdit.out_time = new_time
    else
        payrollToEdit.out_time = new_time
    end
end


def editSalary
    print "\nEnter new Default Salary: "
    new_salary = getValidNumber

    $defaultSalary = new_salary
end


def editDayType
    printChoices($days)
    choice = getValidRange("Enter the Day of the day type to edit: ", $VALID_DAY_RANGE)
    payrollToEdit = $payrolls[choice-1]

    day_types = ["Normal Day", "Rest Day",
                 "Special Non-Working Day", "Special Non-Working Day and Rest Day",
                 "Regular Holiday", "Regular Holiday and Rest Day"]

    printChoices(day_types)
    new_day_type = getValidRange("Enter new day type for #{payrollToEdit.day}: ", $VALID_DAY_TYPE_RANGE) - 1

    payrollToEdit.day_type = new_day_type
end


def dayTypeRates(day_type)
    case day_type
    when $NORM_D
        day_rate = 1
        ot_rate = 1.25
    when $REST_D
        day_rate = 1.3
        ot_rate = 1.69
    when $SNWD
        day_rate = 1.3
        ot_rate = 1.69
    when $SNWD_RD
        day_rate = 1.5
        ot_rate = 1.95
    when $RH_D
        day_rate = 2.0
        ot_rate = 2.6
    when $RH_REST
        day_rate = 2.6
        ot_rate = 3.38
    end
    night_rate = day_rate + 0.1
    night_ot_rate = ot_rate + (ot_rate * 0.1)

    [day_rate, night_rate, ot_rate, night_ot_rate]
end


def calculateWeekly
    $payrolls.each do |day|
        printDayPayroll(day)
        calculateDay(day)
    end
end


def calculateHoursWorked(in_hour, out_hour)
    return 0, 0, 0 if in_hour == out_hour

    req_hrs_with_break = $required_hours + 1

    regular_hrs = [req_hrs_with_break, getHourDiff(in_hour, out_hour)].min
    overtime_hrs = [0, getHourDiff(in_hour, out_hour) - req_hrs_with_break].max

    overtime_start = (in_hour + regular_hrs) % 24

    reg_passed_midnight = in_hour > (in_hour + regular_hrs) % 24
    ot_passed_midnight = overtime_start > (overtime_start + overtime_hrs) % 24

    regular_ns, overtime_ns = 0, 0 # night shift hours

    regular_ns = if reg_passed_midnight
                     [2, 24 - in_hour].min + [$END_NS, overtime_start].min
                 else
                     [0, overtime_start - $NIGHT_SHIFT].max + [0, $END_NS - in_hour].max
                 end

    overtime_ns = if ot_passed_midnight && overtime_hrs.positive?
                      [2, 24 - overtime_start].min + [$END_NS, out_hour].min
                  elsif !ot_passed_midnight && overtime_hrs.positive?
                      [0, out_hour - $NIGHT_SHIFT].max + [0, $END_NS - overtime_start].max
                  else
                    0
                  end

    [regular_ns, (overtime_hrs - overtime_ns).abs, overtime_ns]
end


def calculateDay(dayPayroll = nil)
    dayPayroll ||= dayReport if dayPayroll.nil?

    in_hour, in_minute = dayPayroll.in_time.divmod(100)
    out_hour, out_minute = dayPayroll.out_time.divmod(100)
    day_type = dayPayroll.day_type

    # if there are minutes entered, ceiling it
    if in_minute != 0 && in_hour == out_hour && out_minute < in_minute
        in_hour = (in_hour + 1) % 24
    elsif (in_hour != out_hour) && out_minute + (60 - in_minute) < 60
        in_hour = (in_hour + 1) % 24
    end

    final_salary = 0.0

    night_hours = ot_hours = night_ot_hours = 0
    day_rate = night_rate = ot_rate = night_ot_rate = 1.0
    hourly_rate = Float($defaultSalary / $required_hours)

    night_hours, ot_hours, night_ot_hours = calculateHoursWorked(in_hour, out_hour)

    day_rate, night_rate, ot_rate, night_ot_rate = dayTypeRates(day_type)

    initial_salary = $defaultSalary

    if in_hour == out_hour
        puts "Status: Absent"
        return
    else
        final_salary = (initial_salary * day_rate) + (night_hours * hourly_rate * night_rate) + (ot_hours * hourly_rate * ot_rate) + (night_ot_hours * hourly_rate * night_ot_rate)
    end

    puts "Hours Overtime (Night Shift Overtime): #{ot_hours} (#{night_ot_hours})",
         "Night Shift Hours: #{night_hours}",
         "Salary for the day: #{final_salary.round(2)}"
end
