
require_relative 'printMethods'
require_relative 'salary'
require_relative 'DayPayroll'
require_relative 'inputChecker'

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
