module TimeArrays

using Dates

export TimeTick, TimeArray

export resample, sma

mutable struct TimeTick{DataType, ValType}
    Date::DataType
    Value::ValType

    function TimeTick(Date::DT, Value::VT) where {DT, VT}
        new{DT, VT}(Date, Value)
    end

    function TimeTick(Date::Tuple{DT, VT}) where {DT, VT}
        TimeTick(Date[1], Date[2])
    end

    function Base.show(io::IO, tt::TimeTick{DT, VT}) where {DT, VT}
        print(io, "$(typeof(tt))(datetime = $(tt.Date), value = $(tt.Value))")
    end

    import Base: isless
    function Base.isless(t1::TimeTick, t2::TimeTick)
        return t1.Date < t2.Date
    end

    import Base: isequal
    function Base.isequal(t1::TimeTick, t2::TimeTick)
        return isequal(t1.Date, t2.Date) && isequal(t1.Value, t2.Value)
    end

    import Base: ==
    function Base.:(==)(t1::TimeTick, t2::TimeTick)
        return t1.Date == t2.Date && t1.Value == t2.Value
    end

    import Base: +
    function Base.:+(t1::TimeTick, t2::TimeTick)
        return TimeTick(t1.Date, t1.Value + t2.Value)
    end

    import Base: -
    function Base.:-(t1::TimeTick, t2::TimeTick)
        return TimeTick(t1.Date, t1.Value - t2.Value)
    end

    import Base: *
    function Base.:*(t1::TimeTick, t2::TimeTick)
        return TimeTick(t1.Date, t1.Value * t2.Value)
    end

    import Base: /
    function Base.:/(t1::TimeTick, t2::TimeTick)
        return TimeTick(t1.Date, t1.Value / t2.Value)
    end
end

mutable struct TimeArray{DataType, ValType}
    Dates::Vector{TimeTick{DataType, ValType}}

    function TimeArray(Dates::Vector{TimeTick{DT, VT}}) where {DT, VT}
        new{DT, VT}(Dates)
    end

    function TimeArray(Dates::Vector{Tuple{DT, VT}}) where {DT, VT}
        TimeArray(TimeTick.(Dates))
    end

    function Base.show(io::IO, ta::TimeArray{DT, VT}) where {DT, VT}
        println(io, "$(length(ta.Dates))-element $(typeof(ta))")
        for date in ta.Dates
            println(io, date)
        end
    end

    import Base: length
    function Base.length(ta::TimeArray)
        return length(ta.Dates)
    end

    import Base: getindex
    function Base.getindex(ta::TimeArray, idx...)
        return getindex(ta.Dates, idx...)
    end

    import Base: setindex!
    function Base.setindex!(ta::TimeArray{DT, VT}, val::TimeTick{DT, VT}, idx...) where {DT, VT}
        return setindex!(ta.Dates, val, idx...)
    end

    function BinarySearchLeftBorder(vec, key)
        left = 1
        right = length(vec)
        while (left <= right)
            mid = floor(Int, (right + left) / 2)
            if (vec[mid] < key)
                left = mid + 1
            elseif (vec[mid] > key)
                right = mid - 1
            else
                return vec[mid]
            end
        end
        return left == 1 ? vec[left] : vec[left - 1]
    end

    function (ta::TimeArray)(t::TimeTick)
        return BinarySearchLeftBorder(ta, t)
    end

    function (ta::TimeArray)(t::DateTime)
        return ta(TimeTick(t, 0.0))
    end

    function operation(op::Function, t1::TimeArray, t2::TimeArray)
        if length(t1) < length(t2)
            return t2 + t1
        end

        result = deepcopy(t1)

        for i in 1:length(result)
            result[i] = op(result[i], t2(result[i]))
        end
        return result
    end

    import Base: +
    function Base.:+(t1::TimeArray, t2::TimeArray)
        return operation(+, t1, t2)
    end

    import Base: -
    function Base.:-(t1::TimeArray, t2::TimeArray)
        return operation(-, t1, t2)
    end

    import Base: *
    function Base.:*(t1::TimeArray, t2::TimeArray)
        return operation(*, t1, t2)
    end

    import Base: /
    function Base.:/(t1::TimeArray, t2::TimeArray)
        return operation(/, t1, t2)
    end

    import Base: isequal
    function Base.isequal(t1::TimeArray, t2::TimeArray)
        return all(isequal.(t1.Dates, t2.Dates))
    end

    import Base: ==
    function Base.:(==)(t1::TimeArray, t2::TimeArray)
        return all(t1.Dates .== t2.Dates)
    end
end

function resample(ta::TimeArray, t::Period)
    result = typeof(ta.Dates)()

    cur_date = ta[1].Date
    while cur_date < ta[length(ta)].Date
        push!(result, TimeTick(cur_date, ta(cur_date).Value))
        cur_date += t
    end

    push!(result, ta[length(ta)])

    return TimeArray(result)
end

function sma(ta::TimeArray, p::Period)
    result = deepcopy(ta)

    for i in length(ta):-1:1
        duration = Second(0)
        sum = 0.0
        count = 0
        j = i
        while j > 1
            duration += abs(ta[i].Date - ta[j].Date)
            if duration >= p
                break;
            else
                sum += ta[j].Value
                count += 1
                j -= 1
            end
        end
        result[i].Value = sum / count
    end

    return result
end

end