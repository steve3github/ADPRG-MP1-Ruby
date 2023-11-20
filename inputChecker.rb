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
