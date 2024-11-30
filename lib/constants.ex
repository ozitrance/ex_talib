defmodule ExTalib.Constants do
  @moduledoc false
  use Const

  const explorer_numerical_types, do: [{:s, 8}, {:s, 16}, {:s, 32}, {:s, 64}, {:u, 8}, {:u, 16}, {:u, 32}, {:u, 64}, {:f, 32}, {:f, 64}, {:decimal}]
  const explorer_integer_types, do: [{:s, 8}, {:s, 16}, {:s, 32}, {:s, 64}, {:u, 8}, {:u, 16}, {:u, 32}, {:u, 64}]
  const explorer_double_types, do: [{:f, 32}, {:f, 64}, {:decimal}]
  # def params do @params end

  const required, do: 0
  const optional, do: 1

  enum types do
    unknown 0
    integer 1
    integer_array 2
    double 3
    double_array 4
    prices 5
    open 6
    high 7
    low 8
    close 9
    volume 10
    open_interest 11
    ma_type 12
    series 13
    dataframe 14
    # list 15
    tensor 16
  end
  const types_atoms, do:
  %{
    0 => :unknown,
    1 => :integer,
    2 => :integer_array,
    3 => :double,
    4 => :double_array,
    5 => :prices,
    6 => :open,
    7 => :high,
    8 => :low,
    9 => :close,
    10 => :volume,
    11 => :open_interest,
    12 => :ma_type,
    13 => :series,
    14 => :dataframe,
    # 15 => :list,
    16 => :tensor
  }
  const price_types, do: [5, 6, 7, 8, 9, 10, 11]
  const price_type_index, do:
    %{6 => 0,
      7 => 1,
      8 => 2,
      9 => 3,
      10 => 4,
      11 => 5}


  enum ma_types do
    sma 0
    ema 1
    wma 2
    dema 3
    tema 4
    trima 5
    kama 6
    mama 7
    t3 8
  end
  const talib_ma_types, do: [:sma, :ema, :wma, :dema, :tema, :trima, :kama, :mama, :t3]
  # const ma_types_atoms, do:
  # %{
  #   0 => :sma,
  #   1 => :ema,
  #   2 => :wma,
  #   3 => :dema,
  #   4 => :tema,
  #   5 => :prices,
  #   6 => :trima,
  #   7 => :kama,
  #   8 => :mama,
  #   9 => :t3
  # }

  enum categories do
    overlap_studies 0
    momentum_indicators 1
    volume_indicators 2
    volatility_indicators 3
    price_transform 4
    cycle_indicators 5
    pattern_recognition 6
    statistic_functions 7
    math_transform 8
    math_operators 9
  end

  const categories_strings, do:
    %{
      0 => "Overlap Studies",
      1 => "Momentum Indicators",
      2 => "Volume Indicators",
      3 => "Volatility Indicators",
      4 => "Price Transform",
      5 => "Cycle Indicators",
      6 => "Pattern Recognition",
      7 => "Statistic Functions",
      8 => "Math Transform",
      9 => "Math Operators",
    }

  const options, do:
    %{
     in_columns: [],
     out_columns: []
    }

  enum functions do
    accbands 0
    acos 1
    ad 2
    add 3
    adosc 4
    adx 5
    adxr 6
    apo 7
    aroon 8
    aroonosc 9
    asin 10
    atan 11
    atr 12
    avgprice 13
    avgdev 14
    bbands 15
    beta 16
    bop 17
    cci 18
    cdl2crows 19
    cdl3blackcrows 20
    cdl3inside 21
    cdl3linestrike 22
    cdl3outside 23
    cdl3starsinsouth 24
    cdl3whitesoldiers 25
    cdlabandonedbaby 26
    cdladvanceblock 27
    cdlbelthold 28
    cdlbreakaway 29
    cdlclosingmarubozu 30
    cdlconcealbabyswall 31
    cdlcounterattack 32
    cdldarkcloudcover 33
    cdldoji 34
    cdldojistar 35
    cdldragonflydoji 36
    cdlengulfing 37
    cdleveningdojistar 38
    cdleveningstar 39
    cdlgapsidesidewhite 40
    cdlgravestonedoji 41
    cdlhammer 42
    cdlhangingman 43
    cdlharami 44
    cdlharamicross 45
    cdlhighwave 46
    cdlhikkake 47
    cdlhikkakemod 48
    cdlhomingpigeon 49
    cdlidentical3crows 50
    cdlinneck 51
    cdlinvertedhammer 52
    cdlkicking 53
    cdlkickingbylength 54
    cdlladderbottom 55
    cdllongleggeddoji 56
    cdllongline 57
    cdlmarubozu 58
    cdlmatchinglow 59
    cdlmathold 60
    cdlmorningdojistar 61
    cdlmorningstar 62
    cdlonneck 63
    cdlpiercing 64
    cdlrickshawman 65
    cdlrisefall3methods 66
    cdlseparatinglines 67
    cdlshootingstar 68
    cdlshortline 69
    cdlspinningtop 70
    cdlstalledpattern 71
    cdlsticksandwich 72
    cdltakuri 73
    cdltasukigap 74
    cdlthrusting 75
    cdltristar 76
    cdlunique3river 77
    cdlupsidegap2crows 78
    cdlxsidegap3methods 79
    ceil 80
    cmo 81
    correl 82
    cos 83
    cosh 84
    dema 85
    div 86
    dx 87
    ema 88
    exp 89
    floor 90
    ht_dcperiod 91
    ht_dcphase 92
    ht_phasor 93
    ht_sine 94
    ht_trendline 95
    ht_trendmode 96
    imi 97
    kama 98
    linearreg 99
    linearreg_angle 100
    linearreg_intercept 101
    linearreg_slope 102
    ln 103
    log10 104
    ma 105
    macd 106
    macdext 107
    macdfix 108
    mama 109
    mavp 110
    max 111
    maxindex 112
    medprice 113
    mfi 114
    midpoint 115
    midprice 116
    min 117
    minindex 118
    minmax 119
    minmaxindex 120
    minus_di 121
    minus_dm 122
    mom 123
    mult 124
    natr 125
    obv 126
    plus_di 127
    plus_dm 128
    ppo 129
    roc 130
    rocp 131
    rocr 132
    rocr100 133
    rsi 134
    sar 135
    sarext 136
    sin 137
    sinh 138
    sma 139
    sqrt 140
    stddev 141
    stoch 142
    stochf 143
    stochrsi 144
    sub 145
    sum 146
    t3 147
    tan 148
    tanh 149
    tema 150
    trange 151
    trima 152
    trix 153
    tsf 154
    typprice 155
    ultosc 156
    var 157
    wclprice 158
    willr 159
    wma 160
  end

  # enum flags do
  #   unstable_period 0
  #   overlap 1
  #   line 2
  #   dashed_line 3
  #   candlestick 4
  #   upper_limit 5
  #   lower_limit 6
  #   histogram 7
  # end

end
