using .TimeArrays
using Test

@testset "TimeArrays.jl" begin

    arr1 = TimeArray([
    (DateTime(2023, 01, 01, 01, 01, 1), 1.0),
    (DateTime(2023, 01, 01, 01, 01, 2), 2.0),
    (DateTime(2023, 01, 01, 01, 01, 3), 3.0),
    (DateTime(2023, 01, 01, 01, 01, 4), 4.0),
    (DateTime(2023, 01, 01, 01, 01, 5), 5.0),
    (DateTime(2023, 01, 01, 01, 01, 6), 6.0),
    (DateTime(2023, 01, 01, 01, 01, 7), 8.0),
    ])

    arr2 = TimeArray([
    (DateTime(2023, 01, 01, 01, 01, 1), 1),
    (DateTime(2023, 01, 01, 01, 01, 3), 3),
    (DateTime(2023, 01, 01, 01, 01, 5), 5),
    (DateTime(2023, 01, 01, 01, 01, 7), 8),
    ])

    @test isequal(arr1(DateTime(2023, 01, 01, 01, 01, 7)),
            TimeTick(DateTime(2023, 01, 01, 01, 01, 7), 8))

    @test isequal(arr1 + arr2, 
                TimeArray([
                (DateTime(2023, 01, 01, 01, 01, 1), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 2), 3.0),
                (DateTime(2023, 01, 01, 01, 01, 3), 6.0),
                (DateTime(2023, 01, 01, 01, 01, 4), 7.0),
                (DateTime(2023, 01, 01, 01, 01, 5), 10.0),
                (DateTime(2023, 01, 01, 01, 01, 6), 11.0),
                (DateTime(2023, 01, 01, 01, 01, 7), 16.0),
                ]))

    @test isequal(arr1 * arr2, 
                TimeArray([
                (DateTime(2023, 01, 01, 01, 01, 1), 1.0),
                (DateTime(2023, 01, 01, 01, 01, 2), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 3), 9.0),
                (DateTime(2023, 01, 01, 01, 01, 4), 12.0),
                (DateTime(2023, 01, 01, 01, 01, 5), 25.0),
                (DateTime(2023, 01, 01, 01, 01, 6), 30.0),
                (DateTime(2023, 01, 01, 01, 01, 7), 64.0),
                ]))

    @test isequal(arr1 - arr2, 
                TimeArray([
                (DateTime(2023, 01, 01, 01, 01, 1), 0.0),
                (DateTime(2023, 01, 01, 01, 01, 2), 1.0),
                (DateTime(2023, 01, 01, 01, 01, 3), 0.0),
                (DateTime(2023, 01, 01, 01, 01, 4), 1.0),
                (DateTime(2023, 01, 01, 01, 01, 5), 0.0),
                (DateTime(2023, 01, 01, 01, 01, 6), 1.0),
                (DateTime(2023, 01, 01, 01, 01, 7), 0.0),
                ]))

    @test isequal((arr1 + arr2) / arr1, 
                TimeArray([
                (DateTime(2023, 01, 01, 01, 01, 1), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 2), 1.5),
                (DateTime(2023, 01, 01, 01, 01, 3), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 4), 1.75),
                (DateTime(2023, 01, 01, 01, 01, 5), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 6), 11.0/6.0),
                (DateTime(2023, 01, 01, 01, 01, 7), 2.0),
                ]))

    @test isequal(resample(arr1, Nanosecond(Millisecond(500))), 
                TimeArray([
                (DateTime(2023, 01, 01, 01, 01, 1), 1.0),
                (DateTime(2023, 01, 01, 01, 01, 1, 500), 1.0),
                (DateTime(2023, 01, 01, 01, 01, 2), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 2, 500), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 3), 3.0),
                (DateTime(2023, 01, 01, 01, 01, 3, 500), 3.0),
                (DateTime(2023, 01, 01, 01, 01, 4), 4.0),
                (DateTime(2023, 01, 01, 01, 01, 4, 500), 4.0),
                (DateTime(2023, 01, 01, 01, 01, 5), 5.0),
                (DateTime(2023, 01, 01, 01, 01, 5, 500), 5.0),
                (DateTime(2023, 01, 01, 01, 01, 6), 6.0),
                (DateTime(2023, 01, 01, 01, 01, 6, 500), 6.0),
                (DateTime(2023, 01, 01, 01, 01, 7), 8.0)
                ]))

    @test isequal(sma(arr1, Nanosecond(Second(2))), 
                TimeArray([
                (DateTime(2023, 01, 01, 01, 01, 1), NaN),
                (DateTime(2023, 01, 01, 01, 01, 2), 2.0),
                (DateTime(2023, 01, 01, 01, 01, 3), 2.5),
                (DateTime(2023, 01, 01, 01, 01, 4), 3.5),
                (DateTime(2023, 01, 01, 01, 01, 5), 4.5),
                (DateTime(2023, 01, 01, 01, 01, 6), 5.5),
                (DateTime(2023, 01, 01, 01, 01, 7), 7.0),
                ]))
end
