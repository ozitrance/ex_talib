defmodule ExTalib.Definitions do
  @moduledoc false
  import ExTalib.Constants

  use Const

  # format [talib_name, [input_params: {:name, :type, :required or :optional, ?:default, ?[min, max]}], [output_params: {:name, :type}] ], [...flags]
  const params, do: %{
    0 => [
      "ACCBANDS",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 20, {2, 100000}}
      ],
      [
        {:accbands_upperband, types(:double_array), :upper_limit},
        {:accbands_middleband, types(:double_array), :line},
        {:accbands_lowerband, types(:double_array), :lower_limit}
      ],
      [:overlap],
      categories(:overlap_studies)
    ],
    1 => [
      "ACOS",
      [{:values, types(:double_array), required()}],
      [{:acos, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    2 => [
      "AD",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:volume, types(:volume), required()}
      ],
      [{:ad, types(:double_array), :line}],
      [],
      categories(:volume_indicators)
    ],
    3 => [
      "ADD",
      [
        {:values_a, types(:double_array), required()},
        {:values_b, types(:double_array), required()}
      ],
      [{:add, types(:double_array), :line}],
      [],
      categories(:math_operators)
    ],
    4 => [
      "ADOSC",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:volume, types(:volume), required()},
        {:fast_period, types(:integer), optional(), 3, {2, 100000}},
        {:slow_period, types(:integer), optional(), 10, {2, 100000}}
      ],
      [{:adosc, types(:double_array), :line}],
      [],
      categories(:volume_indicators)
    ],
    5 => [
      "ADX",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:adx, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    6 => [
      "ADXR",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:adxr, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    7 => [
      "APO",
      [
        {:values, types(:double_array), required()},
        {:fast_period, types(:integer), optional(), 12, {2, 100000}},
        {:slow_period, types(:integer), optional(), 26, {2, 100000}},
        {:ma_type, types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [{:apo, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    8 => [
      "AROON",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [
        {:aroon_down, types(:double_array), :dashed_line},
        {:aroon_up, types(:double_array), :line}
      ],
      [],
      categories(:momentum_indicators)
    ],
    9 => [
      "AROONOSC",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:aroonosc, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    10 => [
      "ASIN",
      [{:values, types(:double_array), required()}],
      [{:asin, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    11 => [
      "ATAN",
      [{:values, types(:double_array), required()}],
      [{:atan, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    12 => [
      "ATR",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {1, 100000}}
      ],
      [{:atr, types(:double_array), :line}],
      [:unstable_period],
      categories(:volatility_indicators)
    ],
    13 => [
      "AVGPRICE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:avgprice, types(:double_array), :line}],
      [:overlap],
      categories(:price_transform)
    ],
    14 => [
      "AVGDEV",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:avgdev, types(:double_array), :line}],
      [:overlap],
      categories(:price_transform)
    ],
    15 => [
      "BBANDS",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 5, {2, 100000}},
        {:deviations_up, types(:double), optional(), 2.0, {-3.0e37, 3.0e37}},
        {:deviations_down, types(:double), optional(), 2.0, {-3.0e37, 3.0e37}},
        {:ma_type, types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [
        {:bbands_upperband, types(:double_array), :upper_limit},
        {:bbands_middleband, types(:double_array), :line},
        {:bbands_lowerband, types(:double_array), :lower_limit}
      ],
      [:overlap],
      categories(:overlap_studies)
    ],
    16 => [
      "BETA",
      [
        {:values_a, types(:double_array), required()},
        {:values_b, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 5, {1, 100000}}
      ],
      [{:beta, types(:double_array), :line}],
      [],
      categories(:statistic_functions)
    ],
    17 => [
      "BOP",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:bop, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    18 => [
      "CCI",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:cci, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    19 => [
      "CDL2CROWS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl2crows, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    20 => [
      "CDL3BLACKCROWS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl3blackcrows, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    21 => [
      "CDL3INSIDE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl3inside, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    22 => [
      "CDL3LINESTRIKE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl3linestrike, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    23 => [
      "CDL3OUTSIDE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl3outside, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    24 => [
      "CDL3STARSINSOUTH",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl3starsinsouth, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    25 => [
      "CDL3WHITESOLDIERS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdl3whitesoldiers, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    26 => [
      "CDLABANDONEDBABY",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.3, {0.0, 3.0e37}}
      ],
      [{:cdlabandonedbaby, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    27 => [
      "CDLADVANCEBLOCK",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdladvanceblock, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    28 => [
      "CDLBELTHOLD",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlbelthold, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    29 => [
      "CDLBREAKAWAY",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlbreakaway, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    30 => [
      "CDLCLOSINGMARUBOZU",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlclosingmarubozu, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    31 => [
      "CDLCONCEALBABYSWALL",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlconcealbabyswall, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    32 => [
      "CDLCOUNTERATTACK",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlcounterattack, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    33 => [
      "CDLDARKCLOUDCOVER",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.5, {0.0, 3.0e37}}
      ],
      [{:cdldarkcloudcover, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    34 => [
      "CDLDOJI",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdldoji, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    35 => [
      "CDLDOJISTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdldojistar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    36 => [
      "CDLDRAGONFLYDOJI",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdldragonflydoji, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    37 => [
      "CDLENGULFING",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlengulfing, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    38 => [
      "CDLEVENINGDOJISTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.3, {0.0, 3.0e37}}
      ],
      [{:cdleveningdojistar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    39 => [
      "CDLEVENINGSTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.3, {0.0, 3.0e37}}
      ],
      [{:cdleveningstar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    40 => [
      "CDLGAPSIDESIDEWHITE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlgapsidesidewhite, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    41 => [
      "CDLGRAVESTONEDOJI",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlgravestonedoji, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    42 => [
      "CDLHAMMER",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlhammer, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    43 => [
      "CDLHANGINGMAN",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlhangingman, types(:integer_array), :line}],
      [:cdlhangingman],
      categories(:pattern_recognition)
    ],
    44 => [
      "CDLHARAMI",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlharami, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    45 => [
      "CDLHARAMICROSS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlharamicross, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    46 => [
      "CDLHIGHWAVE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlhighwave, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    47 => [
      "CDLHIKKAKE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlhikkake, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    48 => [
      "CDLHIKKAKEMOD",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlhikkakemod, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    49 => [
      "CDLHOMINGPIGEON",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlhomingpigeon, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    50 => [
      "CDLIDENTICAL3CROWS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlidentical3crows, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    51 => [
      "CDLINNECK",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlinneck, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    52 => [
      "CDLINVERTEDHAMMER",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlinvertedhammer, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    53 => [
      "CDLKICKING",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlkicking, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    54 => [
      "CDLKICKINGBYLENGTH",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlkickingbylength, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    55 => [
      "CDLLADDERBOTTOM",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlladderbottom, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    56 => [
      "CDLLONGLEGGEDDOJI",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdllongleggeddoji, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    57 => [
      "CDLLONGLINE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdllongline, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    58 => [
      "CDLMARUBOZU",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlmarubozu, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    59 => [
      "CDLMATCHINGLOW",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlmatchinglow, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    60 => [
      "CDLMATHOLD",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.5, {0.0, 3.0e37}}
      ],
      [{:cdlmathold, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    61 => [
      "CDLMORNINGDOJISTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.3, {0.0, 3.0e37}}
      ],
      [{:cdlmorningdojistar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    62 => [
      "CDLMORNINGSTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:penetration, types(:double), optional(), 0.3, {0.0, 3.0e37}}
      ],
      [{:cdlmorningstar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    63 => [
      "CDLONNECK",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlonneck, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    64 => [
      "CDLPIERCING",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlpiercing, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    65 => [
      "CDLRICKSHAWMAN",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlrickshawman, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    66 => [
      "CDLRISEFALL3METHODS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlrisefall3methods, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    67 => [
      "CDLSEPARATINGLINES",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlseparatinglines, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    68 => [
      "CDLSHOOTINGSTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlshootingstar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    69 => [
      "CDLSHORTLINE",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlshortline, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    70 => [
      "CDLSPINNINGTOP",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlspinningtop, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    71 => [
      "CDLSTALLEDPATTERN",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlstalledpattern, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    72 => [
      "CDLSTICKSANDWICH",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlsticksandwich, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    73 => [
      "CDLTAKURI",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdltakuri, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    74 => [
      "CDLTASUKIGAP",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdltasukigap, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    75 => [
      "CDLTHRUSTING",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlthrusting, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    76 => [
      "CDLTRISTAR",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdltristar, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    77 => [
      "CDLUNIQUE3RIVER",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlunique3river, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    78 => [
      "CDLUPSIDEGAP2CROWS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlupsidegap2crows, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    79 => [
      "CDLXSIDEGAP3METHODS",
      [
        {:open, types(:open), required()},
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:cdlxsidegap3methods, types(:integer_array), :line}],
      [:candlestick],
      categories(:pattern_recognition)
    ],
    80 => [
      "CEIL",
      [{:values, types(:double_array), required()}],
      [{:ceil, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    81 => [
      "CMO",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:cmo, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    82 => [
      "CORREL",
      [
        {:values_a, types(:double_array), required()},
        {:values_b, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {1, 100000}}
      ],
      [{:correl, types(:double_array), :line}],
      [],
      categories(:statistic_functions)
    ],
    83 => [
      "COS",
      [{:values, types(:double_array), required()}],
      [{:cos, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    84 => [
      "COSH",
      [{:values, types(:double_array), required()}],
      [{:cosh, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    85 => [
      "DEMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:dema, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    86 => [
      "DIV",
      [
        {:values_a, types(:double_array), required()},
        {:values_b, types(:double_array), required()}
      ],
      [{:div, types(:double_array), :line}],
      [],
      categories(:math_operators)
    ],
    87 => [
      "DX",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:dx, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    88 => [
      "EMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:ema, types(:double_array), :line}],
      [:overlap, :unstable_period],
      categories(:overlap_studies)
    ],
    89 => [
      "EXP",
      [{:values, types(:double_array), required()}],
      [{:exp, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    90 => [
      "FLOOR",
      [{:values, types(:double_array), required()}],
      [{:floor, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    91 => [
      "HT_DCPERIOD",
      [{:values, types(:double_array), required()}],
      [{:ht_dcperiod, types(:double_array), :line}],
      [:unstable_period],
      categories(:cycle_indicators)
    ],
    92 => [
      "HT_DCPHASE",
      [{:values, types(:double_array), required()}],
      [{:ht_dcphase, types(:double_array), :line}],
      [:unstable_period],
      categories(:cycle_indicators)
    ],
    93 => [
      "HT_PHASOR",
      [{:values, types(:double_array), required()}],
      [
        {:inphase, types(:double_array), :line},
        {:quadrature, types(:double_array), :dashed_line}
      ],
      [:unstable_period],
      categories(:cycle_indicators)
    ],
    94 => [
      "HT_SINE",
      [{:values, types(:double_array), required()}],
      [
        {:sine, types(:double_array), :line},
        {:leadsine, types(:double_array), :dashed_line}
      ],
      [:unstable_period],
      categories(:cycle_indicators)
    ],
    95 => [
      "HT_TRENDLINE",
      [{:values, types(:double_array), required()}],
      [{:ht_trendline, types(:double_array), :line}],
      [:overlap, :unstable_period],
      categories(:overlap_studies)
    ],
    96 => [
      "HT_TRENDMODE",
      [{:values, types(:double_array), required()}],
      [{:ht_trendmode, types(:integer_array), :line}],
      [:unstable_period],
      categories(:cycle_indicators)
    ],
    97 => [
      "IMI",
      [
        {:open, types(:open), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:imi, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    98 => [
      "KAMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:kama, types(:double_array), :line}],
      [:overlap, :unstable_period],
      categories(:overlap_studies)
    ],
    99 => [
      "LINEARREG",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:linearreg, types(:double_array), :line}],
      [:overlap],
      categories(:statistic_functions)
    ],
    100 => [
      "LINEARREG_ANGLE",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:linearreg_angle, types(:double_array), :line}],
      [],
      categories(:statistic_functions)
    ],
    101 => [
      "LINEARREG_INTERCEPT",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:linearreg_intercept, types(:double_array), :line}],
      [:overlap],
      categories(:statistic_functions)
    ],
    102 => [
      "LINEARREG_SLOPE",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:linearreg_slope, types(:double_array), :line}],
      [],
      categories(:statistic_functions)
    ],
    103 => [
      "LN",
      [{:values, types(:double_array), required()}],
      [{:ln, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    104 => [
      "LOG10",
      [{:values, types(:double_array), required()}],
      [{:log10, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    105 => [
      "MA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {1, 100000}},
        {:ma_type, types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [{:ma, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    106 => [
      "MACD",
      [
        {:values, types(:double_array), required()},
        {:fast_period, types(:integer), optional(), 12, {2, 100000}},
        {:slow_period, types(:integer), optional(), 26, {2, 100000}},
        {:signal_period, types(:integer), optional(), 9, {1, 100000}}
      ],
      [
        {:macd, types(:double_array), :line},
        {:macdsignal, types(:double_array), :dashed_line},
        {:macdhist, types(:double_array), :histogram}
      ],
      [],
      categories(:momentum_indicators)
    ],
    107 => [
      "MACDEXT",
      [
        {:values, types(:double_array), required()},
        {:fast_period, types(:integer), optional(), 12, {2, 100000}},
        {:fast_ma, types(:ma_type), optional(), :sma, {0, 8}},
        {:slow_period, types(:integer), optional(), 26, {2, 100000}},
        {:slow_ma, types(:ma_type), optional(), :sma, {0, 8}},
        {:signal_period, types(:integer), optional(), 9, {1, 100000}},
        {:signal_ma, types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [
        {:macdext, types(:double_array), :line},
        {:macdextsignal, types(:double_array), :dashed_line},
        {:macdexthist, types(:double_array), :histogram}
      ],
      [],
      categories(:momentum_indicators)
    ],
    108 => [
      "MACDFIX",
      [
        {:values, types(:double_array), required()},
        {:signal_period, types(:integer), optional(), 9, {1, 100000}}
      ],
      [
        {:macdfix, types(:double_array), :line},
        {:macdfixsignal, types(:double_array), :dashed_line},
        {:macdfixhist, types(:double_array), :histogram}
      ],
      [],
      categories(:momentum_indicators)
    ],
    109 => [
      "MAMA",
      [
        {:values, types(:double_array), required()},
        {:fast_limit, types(:double), optional(), 0.5, {0.01, 0.99}},
        {:slow_limit, types(:double), optional(), 0.05, {0.01, 0.99}}
      ],
      [{:mama, types(:double_array), :line}, {:fama, types(:double_array), :dashed_line}],
      [:overlap, :unstable_period],
      categories(:overlap_studies)
    ],
    110 => [
      "MAVP",
      [
        {:values, types(:double_array), required()},
        {:periods, types(:double_array), required()},
        {:minimum_period, types(:integer), optional(), 2, {2, 100000}},
        {:maximum_period, types(:integer), optional(), 30, {2, 100000}},
        {:ma_type, types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [{:mavp, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    111 => [
      "MAX",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:max, types(:double_array), :line}],
      [:overlap],
      categories(:math_operators)
    ],
    112 => [
      "MAXINDEX",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:maxindex, types(:integer_array), :line}],
      [],
      categories(:math_operators)
    ],
    113 => [
      "MEDPRICE",
      [{:high, types(:high), required()}, {:low, types(:low), required()}],
      [{:medprice, types(:double_array), :line}],
      [:overlap],
      categories(:price_transform)
    ],
    114 => [
      "MFI",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:volume, types(:volume), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:mfi, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    115 => [
      "MIDPOINT",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:midpoint, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    116 => [
      "MIDPRICE",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:midprice, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    117 => [
      "MIN",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:min, types(:double_array), :line}],
      [:overlap],
      categories(:math_operators)
    ],
    118 => [
      "MININDEX",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:minindex, types(:integer_array), :line}],
      [],
      categories(:math_operators)
    ],
    119 => [
      "MINMAX",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:min, types(:double_array), :line}, {:max, types(:double_array), :line}],
      [:overlap],
      categories(:math_operators)
    ],
    120 => [
      "MINMAXINDEX",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:minidx, types(:integer_array), :line}, {:maxidx, types(:integer_array), :line}],
      [],
      categories(:math_operators)
    ],
    121 => [
      "MINUS_DI",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {1, 100000}}
      ],
      [{:minus_di, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    122 => [
      "MINUS_DM",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:time_period, types(:integer), optional(), 14, {1, 100000}}
      ],
      [{:minus_dm, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    123 => [
      "MOM",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 10, {1, 100000}}
      ],
      [{:mom, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    124 => [
      "MULT",
      [
        {:values_a, types(:double_array), required()},
        {:values_b, types(:double_array), required()}
      ],
      [{:mult, types(:double_array), :line}],
      [],
      categories(:math_operators)
    ],
    125 => [
      "NATR",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {1, 100000}}
      ],
      [{:natr, types(:double_array), :line}],
      [:unstable_period],
      categories(:volatility_indicators)
    ],
    126 => [
      "OBV",
      [{:values, types(:double_array), required()}, {:volume, types(:volume), required()}],
      [{:obv, types(:double_array), :line}],
      [],
      categories(:volume_indicators)
    ],
    127 => [
      "PLUS_DI",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {1, 100000}}
      ],
      [{:plus_di, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    128 => [
      "PLUS_DM",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:time_period, types(:integer), optional(), 14, {1, 100000}}
      ],
      [{:plus_dm, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    129 => [
      "PPO",
      [
        {:values, types(:double_array), required()},
        {:fast_period, types(:integer), optional(), 12, {2, 100000}},
        {:slow_period, types(:integer), optional(), 26, {2, 100000}},
        {:ma_type, types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [{:ppo, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    130 => [
      "ROC",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 10, {1, 100000}}
      ],
      [{:roc, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    131 => [
      "ROCP",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 10, {1, 100000}}
      ],
      [{:rocp, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    132 => [
      "ROCR",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 10, {1, 100000}}
      ],
      [{:rocr, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    133 => [
      "ROCR100",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 10, {1, 100000}}
      ],
      [{:rocr100, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    134 => [
      "RSI",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:rsi, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    135 => [
      "SAR",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:acceleration_factor, types(:double), optional(), 0.02, {0.0, 3.0e37}},
        {:af_maximum, types(:double), optional(), 0.2, {0.0, 3.0e37}}
      ],
      [{:sar, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    136 => [
      "SAREXT",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:start_value, types(:double), optional(), 0.0, {-3.0e37, 3.0e37}},
        {:offset_on_reverse, types(:double), optional(), 0.0, {0.0, 3.0e37}},
        {:af_init_long, types(:double), optional(), 0.02, {0.0, 3.0e37}},
        {:af_long, types(:double), optional(), 0.02, {0.0, 3.0e37}},
        {:af_max_long, types(:double), optional(), 0.2, {0.0, 3.0e37}},
        {:af_init_short, types(:double), optional(), 0.02, {0.0, 3.0e37}},
        {:af_short, types(:double), optional(), 0.02, {0.0, 3.0e37}},
        {:af_max_short, types(:double), optional(), 0.2, {0.0, 3.0e37}}
      ],
      [{:sarext, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    137 => [
      "SIN",
      [{:values, types(:double_array), required()}],
      [{:sin, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    138 => [
      "SINH",
      [{:values, types(:double_array), required()}],
      [{:sinh, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    139 => [
      "SMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:sma, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    140 => [
      "SQRT",
      [{:values, types(:double_array), required()}],
      [{:sqrt, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    141 => [
      "STDDEV",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 5, {2, 100000}},
        {:deviations, types(:double), optional(), 1.0, {-3.0e37, 3.0e37}}
      ],
      [{:stddev, types(:double_array), :line}],
      [],
      categories(:statistic_functions)
    ],
    142 => [
      "STOCH",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:"fast-k_period", types(:integer), optional(), 5, {1, 100000}},
        {:"slow-k_period", types(:integer), optional(), 3, {1, 100000}},
        {:"slow-k_ma", types(:ma_type), optional(), :sma, {0, 8}},
        {:"slow-d_period", types(:integer), optional(), 3, {1, 100000}},
        {:"slow-d_ma", types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [
        {:slowk, types(:double_array), :dashed_line},
        {:slowd, types(:double_array), :dashed_line}
      ],
      [],
      categories(:momentum_indicators)
    ],
    143 => [
      "STOCHF",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:"fast-k_period", types(:integer), optional(), 5, {1, 100000}},
        {:"fast-d_period", types(:integer), optional(), 3, {1, 100000}},
        {:"fast-d_ma", types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [{:fastk, types(:double_array), :line}, {:fastd, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    144 => [
      "STOCHRSI",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}},
        {:"fast-k_period", types(:integer), optional(), 5, {1, 100000}},
        {:"fast-d_period", types(:integer), optional(), 3, {1, 100000}},
        {:"fast-d_ma", types(:ma_type), optional(), :sma, {0, 8}}
      ],
      [{:fastk, types(:double_array), :line}, {:fastd, types(:double_array), :line}],
      [:unstable_period],
      categories(:momentum_indicators)
    ],
    145 => [
      "SUB",
      [
        {:values_a, types(:double_array), required()},
        {:values_b, types(:double_array), required()}
      ],
      [{:sub, types(:double_array), :line}],
      [],
      categories(:math_operators)
    ],
    146 => [
      "SUM",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:sum, types(:double_array), :line}],
      [],
      categories(:math_operators)
    ],
    147 => [
      "T3",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 5, {2, 100000}},
        {:volume_factor, types(:double), optional(), 0.7, {0.0, 1.0}}
      ],
      [{:t3, types(:double_array), :line}],
      [:overlap, :unstable_period],
      categories(:overlap_studies)
    ],
    148 => [
      "TAN",
      [{:values, types(:double_array), required()}],
      [{:tan, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    149 => [
      "TANH",
      [{:values, types(:double_array), required()}],
      [{:tanh, types(:double_array), :line}],
      [],
      categories(:math_transform)
    ],
    150 => [
      "TEMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:tema, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    151 => [
      "TRANGE",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:trange, types(:double_array), :line}],
      [],
      categories(:volatility_indicators)
    ],
    152 => [
      "TRIMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:trima, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ],
    153 => [
      "TRIX",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {1, 100000}}
      ],
      [{:trix, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    154 => [
      "TSF",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:tsf, types(:double_array), :line}],
      [:overlap],
      categories(:statistic_functions)
    ],
    155 => [
      "TYPPRICE",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:typprice, types(:double_array), :line}],
      [:overlap],
      categories(:price_transform)
    ],
    156 => [
      "ULTOSC",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:first_period, types(:integer), optional(), 7, {1, 100000}},
        {:second_period, types(:integer), optional(), 14, {1, 100000}},
        {:third_period, types(:integer), optional(), 28, {1, 100000}}
      ],
      [{:ultosc, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    157 => [
      "VAR",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 5, {1, 100000}},
        {:deviations, types(:double), optional(), 1.0, {-3.0e37, 3.0e37}}
      ],
      [{:var, types(:double_array), :line}],
      [],
      categories(:statistic_functions)
    ],
    158 => [
      "WCLPRICE",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()}
      ],
      [{:wclprice, types(:double_array), :line}],
      [:overlap],
      categories(:price_transform)
    ],
    159 => [
      "WILLR",
      [
        {:high, types(:high), required()},
        {:low, types(:low), required()},
        {:close, types(:close), required()},
        {:time_period, types(:integer), optional(), 14, {2, 100000}}
      ],
      [{:willr, types(:double_array), :line}],
      [],
      categories(:momentum_indicators)
    ],
    160 => [
      "WMA",
      [
        {:values, types(:double_array), required()},
        {:time_period, types(:integer), optional(), 30, {2, 100000}}
      ],
      [{:wma, types(:double_array), :line}],
      [:overlap],
      categories(:overlap_studies)
    ]
  }


end
