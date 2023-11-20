##
# DayPayroll class that keeps track of:
#            day - String that represents the day (eg: Monday)
#            in_time, out_time - integer that indicates IN and OUT times.
#            day_type - an integer value ranging 0 to 5 inclusive that keeps track of the type of day
class DayPayroll
    attr_accessor :day, :in_time, :out_time, :day_type

    def initialize(day, in_time, out_time, day_type)
        @day = day
        @in_time = in_time
        @out_time = out_time
        @day_type = day_type
    end
end

