defmodule ExTalibTest do
  use ExUnit.Case
  import ExTalib
  import ExTalib.{Constants,
                  Errors}
  import TestHelper

  describe "accbands" do
    @valid_out_1 [:nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan,
    :nan, :nan, :nan, :nan, :nan, 68162.87045188263, 67937.55554415323,
    67449.38294087091, 67837.36139986811, 67683.36445048256, 67151.5018464851,
    67381.1616365639, 67878.77497994639, 67132.49906397684, 67130.92155855337,
    67172.60307580893, 66732.34140424189]
    @valid_out_2 [:nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan,
    :nan, :nan, :nan, :nan, :nan, 59195.91499999999, 58985.469999999994,
    58928.77999999999, 59095.544999999984, 59394.14499999998,
    59903.49999999998, 60244.319999999985, 60458.39999999999,
    60325.90999999999, 60251.63999999998, 60161.959999999985,
    60174.39999999998]
    @valid_out_3 [:nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan,
    :nan, :nan, :nan, :nan, :nan, 50933.52045188263, 50786.65554415324,
    50964.082940870925, 50768.93639986812, 51389.86445048257,
    52846.70184648512, 53418.61163656392, 53394.0749799464,
    54069.549063976854, 54001.99655855338, 53756.57807580894,
    54068.46640424192]
    test "accbands valid" do
      series_inputs = build_test_inputs(:accbands, :valid, :series)
      dataframe_inputs = build_test_inputs(:accbands, :valid, :series, true)
      tensor_inputs = build_test_inputs(:accbands, :valid, :tensor)

      assert(apply(&accbands/5, series_inputs) |> elem(1) |> List.first |> Explorer.Series.to_list === @valid_out_1)
      assert((apply(&accbands/5, dataframe_inputs) |> elem(1))["accbands_upperband_20" |> String.to_atom] |> Explorer.Series.to_list === @valid_out_1)
      assert(apply(&accbands/5, tensor_inputs) === {:ok, [@valid_out_1 |> Nx.tensor(type: :f64), @valid_out_2 |> Nx.tensor(type: :f64), @valid_out_3 |> Nx.tensor(type: :f64)]})

      # Bang!
      assert(apply(&accbands!/5, series_inputs) |> List.first |> Explorer.Series.to_list === @valid_out_1)
      assert((apply(&accbands!/5, dataframe_inputs))["accbands_upperband_20" |> String.to_atom] |> Explorer.Series.to_list === @valid_out_1)
      assert(apply(&accbands!/5, tensor_inputs) === [@valid_out_1 |> Nx.tensor(type: :f64), @valid_out_2 |> Nx.tensor(type: :f64), @valid_out_3 |> Nx.tensor(type: :f64)])
    end
  end




  describe "acos" do
    @valid_out_1 [1.3737453568764886, 1.385482602037588, 1.3879185141841766,
    1.395654342220921, 1.4082444498573286, 1.402203875538758, 1.404903609613873,
    1.384945643879787, 1.3875405948626018, 1.3872927995238935,
    1.3939845036820064, 1.392064760615401, 1.3883271859187964,
    1.3941214941845559, 1.397581987550128, 1.393491918995786, 1.3916234760212745,
    1.3949071461917495, 1.3918366613827209, 1.3931022043907781,
    1.386591412882129, 1.3889384598849808, 1.377744006006369, 1.3774490261399694,
    1.3772239627565261, 1.3814444749324049, 1.3918792974681502,
    1.393019691005026, 1.3920659787436032, 1.3927569188221773,
    1.3932270378163907]
    test "acos valid" do
      # list_inputs = build_test_inputs(:acos, :valid, :list)
      series_inputs = build_test_inputs(:acos, :valid_normalized, :series)
      tensor_inputs = build_test_inputs(:acos, :valid_normalized, :tensor)

      # assert(apply(&acos/2, list_inputs) === {:ok, [@valid_out_1]})
      assert(apply(&acos/2, series_inputs) |> elem(1) |> List.first |> Explorer.Series.to_list === @valid_out_1 )
      assert(apply(&acos/2, tensor_inputs) === {:ok, [@valid_out_1 |> Nx.tensor(type: :f64)]})
      # Bang!
      # assert(apply(&acos!/2, list_inputs) === [@valid_out_1])
      assert(apply(&acos!/2, series_inputs) |> List.first |> Explorer.Series.to_list === @valid_out_1)
      assert(apply(&acos!/2, tensor_inputs) === [@valid_out_1 |> Nx.tensor(type: :f64)])
    end
  end





  describe "ad" do
    @valid_out_1 [301825.071325323, -65182.7779060789, -138450.93925045797,
    -292759.52050925535, -179372.67126280162, -29470.25283087688,
    -268458.6250691761, 76050.16278421204, 130296.97384297174,
    141590.95196637113, -13599.219709963101, 30465.56147587725,
    126571.66079016298, -121257.2046513343, -193120.57275883883,
    -107345.10868190932, -67379.17365063186, -211046.71896570036,
    -40595.88973915606, -231766.29199538627, -80168.80632530496,
    -125703.33446237858, 97213.40672197836, 130447.7974311806,
    88336.91372894305, -94449.53371336438, -246134.91370804876,
    -245844.5886818064, -354202.284230825, -269708.49862628046,
    -293306.56273334543]
    test "ad valid" do
      series_inputs = build_test_inputs(:ad, :valid, :series)
      tensor_inputs = build_test_inputs(:ad, :valid, :tensor)

      assert(apply(&ad/5, series_inputs) |> elem(1) |> List.first |> Explorer.Series.to_list === @valid_out_1 )
      assert(apply(&ad/5, tensor_inputs) === {:ok, [@valid_out_1 |> Nx.tensor(type: :f64)]})
      # Bang!
      assert(apply(&ad!/5, series_inputs) |> List.first |> Explorer.Series.to_list === @valid_out_1)
      assert(apply(&ad!/5, tensor_inputs) === [@valid_out_1 |> Nx.tensor(type: :f64)])
    end

  end












  describe "rsi" do
    @valid_out_1 [:nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan, :nan,
      36.420325652329495, 39.46397607267759, 40.856136366517696, 39.15183288748458,
      41.604884003816544, 40.87359961334125, 46.118262393338526, 44.58358164027796,
      52.66728154791546, 52.8621927729173, 53.02113998757058, 49.63951952268519,
      42.42502900104559, 41.710790208274084, 42.58140978121209, 42.09092430999695,
      41.738600914759935]

    test "rsi valid" do
      # list_inputs = build_test_inputs(:rsi, :valid, :list)
      series_inputs = build_test_inputs(:rsi, :valid, :series)
      tensor_inputs = build_test_inputs(:rsi, :valid, :tensor)

      # assert(apply(&rsi/3, list_inputs) === {:ok, [@valid_out_1]})
      assert(apply(&rsi/3, series_inputs) |> elem(1) |> List.first |> Explorer.Series.to_list === @valid_out_1)
      assert(apply(&rsi/3, tensor_inputs) === {:ok, [@valid_out_1 |> Nx.tensor(type: :f64)]})
      # Bang!
      # assert(apply(&rsi!/3, list_inputs) === [@valid_out_1])
      assert(apply(&rsi!/3, series_inputs) |> List.first |> Explorer.Series.to_list === @valid_out_1)
      assert(apply(&rsi!/3, tensor_inputs) === [@valid_out_1 |> Nx.tensor(type: :f64)])
    end

    test "rsi bad input type" do
      def_for_error = {:values, types(:double_array)}

      # list_inputs = build_test_inputs(:rsi, :bad_input_type_int_array, :list)
      # assert(apply(&rsi/3, list_inputs) === {:error, [build_input_error(List.first(list_inputs), def_for_error, :match_type)]})
      # list_inputs = build_test_inputs(:rsi, :bad_input_type_string_array, :list)
      # assert(apply(&rsi/3, list_inputs) === {:error, [build_input_error(List.first(list_inputs), def_for_error, :match_type)]})

      series_inputs = build_test_inputs(:rsi, :bad_input_type_int_array, :series)
      assert(apply(&rsi/3, series_inputs) === {:error, [build_input_error(List.first(series_inputs), def_for_error, :match_type)]})
      series_inputs = build_test_inputs(:rsi, :bad_input_type_string_array, :series)
      assert(apply(&rsi/3, series_inputs) === {:error, [build_input_error(List.first(series_inputs), def_for_error, :match_type)]})

      tensor_inputs = build_test_inputs(:rsi, :bad_input_type_int_array, :tensor)
      assert(apply(&rsi/3, tensor_inputs) === {:error, [build_input_error(List.first(tensor_inputs), def_for_error, :match_type)]})
    end

    test "rsi bad no nils" do
      def_for_error = {:values, types(:double_array)}

      # series_inputs = build_test_inputs(:rsi, :with_nans, :series)
      # assert(apply(&rsi/3, series_inputs) === {:error, [build_input_error(List.first(series_inputs), def_for_error, :no_nulls)]})

      tensor_inputs = build_test_inputs(:rsi, :with_nans, :tensor)
      assert(apply(&rsi/3, tensor_inputs) === {:error, [build_input_error(List.first(tensor_inputs), def_for_error, :no_nulls)]})
    end

    test "rsi bad empty list" do
      def_for_error = {:values, types(:double_array)}
      # list_inputs = build_test_inputs(:rsi, :empty_list, :series)
      # assert(apply(&rsi/3, list_inputs) === {:error, [build_input_error(List.first(list_inputs), def_for_error, :not_empty),
      #                                                 build_input_error(List.first(list_inputs), def_for_error, :match_type)]})

      series_inputs = build_test_inputs(:rsi, :empty_list, :series)
      assert(apply(&rsi/3, series_inputs) === {:error, [build_input_error(List.first(series_inputs), def_for_error, :not_empty),
                                                        build_input_error(List.first(series_inputs), def_for_error, :match_type)]})
    end

    test "rsi bad nx shape" do
      def_for_error = {:values, types(:double_array)}
      tensor_inputs = build_test_inputs(:rsi, :nx_shape, :tensor)
      assert(apply(&rsi/3, tensor_inputs) === {:error, [build_input_error(List.first(tensor_inputs), def_for_error, :shape)]})
    end

    test "rsi bad min_max" do
      def_for_error = {:time_period, types(:integer), optional(), 14, {2, 100000}}
      # list_inputs = build_test_inputs(:rsi, :bad_min_max, :list)
      # [_input | list_without_first_el] = list_inputs
      series_inputs = build_test_inputs(:rsi, :bad_min_max, :series)
      [_input | series_without_first_el] = series_inputs
      tensor_inputs = build_test_inputs(:rsi, :bad_min_max, :tensor)
      [_input | tensor_without_first_el] = tensor_inputs
      # assert(apply(&rsi/3, list_inputs) === {:error, [build_input_error(List.first(list_without_first_el), def_for_error, :min_max)]})
      assert(apply(&rsi/3, series_inputs) === {:error, [build_input_error(List.first(series_without_first_el), def_for_error, :min_max)]})
      assert(apply(&rsi/3, tensor_inputs) === {:error, [build_input_error(List.first(tensor_without_first_el), def_for_error, :min_max)]})
    end

    # test "rsi bad ma_type" do

    # end

    # test "rsi bad multiple_lengths" do

    # end




  end

end
