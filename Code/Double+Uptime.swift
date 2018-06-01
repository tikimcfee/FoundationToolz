import Darwin.Mach

public extension Double
{
    static var uptimeMilliseconds: Double
    {
        let ticks = mach_absolute_time()
        
        var timeBase = mach_timebase_info_data_t()
        
        mach_timebase_info(&timeBase)
        
        let nanoSeconds = ticks * UInt64(timeBase.numer) / UInt64(timeBase.denom)
        
        return Double(nanoSeconds) / 1000000.0
    }
}
