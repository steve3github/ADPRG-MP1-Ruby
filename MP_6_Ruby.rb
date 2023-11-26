=begin
********************
Last names:
Language:
Paradigm(s):
********************
=end

# GitHub Link: https://github.com/steve3github/ADPRG-MP1-Ruby.git

# Class
class DayPayroll
  attr_accessor :day, :in_time, :out_time, :day_type

  def initialize(day, in_time, out_time, day_type)
      @day = day
      @in_time = in_time
      @out_time = out_time
      @day_type = day_type
  end
end


# Input Checkers
def getValidRange(strPrompt, range)
  loop do
      begin
          print strPrompt
          input = gets.chomp
          int_value = Integer(input)

          if range.include?(int_value)
              return int_value
          else
              puts "Please enter a valid option."
          end
      rescue ArgumentError
          puts "Invalid input. Please enter a valid integer."
          retry
      end
  end
end


def getValidTime(in_or_out, in_time, time_range)
  loop do
      begin
          print "Enter New #{in_or_out} Time: "
          input = gets.chomp
          int_value = Integer(input)

          hour_diff = getHourDiff((in_time / 100), (int_value / 100))

          if !int_value.positive?
              puts "Please enter a positive number."
          elsif (int_value % 100) >= 60
              puts "Please enter a valid minute time."
          elsif !time_range.include?(int_value)
              puts "Please enter a valid time within 24 hours."
          elsif hour_diff < 9
              puts "You are required to work at least 8 hours. Please try again."
          else
              return int_value
          end
      rescue ArgumentError
          puts "Invalid input. Please enter a valid integer."
          retry
      end
  end
end


def getValidNumber
  begin
      input = gets.chomp
      int_value = Integer(input)
      if !int_value.positive?
          puts "Please enter a positive number."
      else
          return int_value
      end
  rescue ArgumentError
      puts "Invalid input. Please enter a valid number."
      retry
  end
end


def getValidDecision(strPrompt)
  loop do
      print strPrompt
      input = gets.chomp
      if !['y','n'].include?(input)
          puts "Please decide Yes or No. (y/n)"
      else
          return input
      end
  end
end


# Print Methods
def printDayPayroll(payroll)
  puts "\n#{payroll.day}'s Payroll"
  puts "Daily Rate: #{$defaultSalary}"
  puts "IN Time: #{payroll.in_time}"
  puts "OUT Time: #{payroll.out_time}"

  case payroll.day_type
  when 0
      dayType = "Normal Day"
  when 1
      dayType = "Rest Day"
  when 2
      dayType = "Special Non-Working Day"
  when 3
      dayType = "Special Non-Working Day and Rest Day"
  when 4
      dayType = "Regular Holiday"
  when 5
      dayType = "Regular Holiday and Rest Day"
  end

  puts "Day Type: #{dayType}"
end

def printChoices(choices)
  exit_no = 1
  choices.each_with_index do |opt, index|
      puts "[#{index+1}] #{opt}"
      exit_no = index+1
  end
  puts "[#{exit_no+1}] Exit"
end


# Calculations
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
        prompt = "Editing the IN time will affect the OUT time to match each other. Do you wish to proceed? (y/n): "
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
    total_weekly = 0
    $payrolls.each do |day|
        printDayPayroll(day)
        total_weekly += calculateDay(day)
    end

    puts "\n--------------------------------",
         "Total Weekly Salary: #{total_weekly}",
         "--------------------------------"
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
      if day_type == $REST_D || day_type == $SNWD_RD || day_type == $RH_REST
          final_salary = initial_salary
      else
          puts "Status: Absent"
          return 0
    end
    else
        final_salary = (initial_salary * day_rate) + (night_hours * hourly_rate * night_rate) + (ot_hours * hourly_rate * ot_rate) + (night_ot_hours * hourly_rate * night_ot_rate)
    end

    puts "Hours Overtime (Night Shift Overtime): #{ot_hours} (#{night_ot_hours})",
         "Night Shift Hours: #{night_hours}",
         "Salary for the day: #{final_salary.round(2)}"

    final_salary
end


# Main
$defaultSalary = 500.00
$required_hours = 8
$days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
$payrolls = []

def initializePayrolls()
    $days.each do |day|
        in_time = 900
        out_time = 900
        day_type = (day != "Saturday" && day != "Sunday") ? 0 : 1
        payroll = DayPayroll.new(day, in_time, out_time, day_type)
        $payrolls << payroll
    end
end

def menu
    in_time = 0
    out_time = 1
    menuOpts = ["Display Weekly Report", "Display Day Report",
                "Edit In Time", "Edit Out Time", "Edit Salary", "Edit Day Type",
                "Calculate Weekly Salary", "Calculate Day Salary"]

    puts "\nMenu:"
    printChoices(menuOpts)
    choice = getValidRange("Enter your choice: ", 1..9)

    case choice
    when 1
        weeklyReport
    when 2
        dayReport
    when 3
        editTime(in_time)
    when 4
        editTime(out_time)
    when 5
        editSalary
    when 6
        editDayType
    when 7
        calculateWeekly
    when 8
        calculateDay
    when 9
        puts "Exiting. Thank you."
        exit
    end
end

initializePayrolls

while true
    menu
end
