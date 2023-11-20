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
