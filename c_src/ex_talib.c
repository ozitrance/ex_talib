#include <ta-lib/ta_abstract.h>
#include <erl_nif.h>

typedef enum {
    TYPE_UNKNOWN = 0,
    TYPE_INT,
    TYPE_INT_ARRAY,
    TYPE_DOUBLE,
    TYPE_DOUBLE_ARRAY,
    TYPE_PRICES,
} DataType;

static ERL_NIF_TERM call(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {

    if (argc != 3) {
        return enif_make_badarg(env);
    }

    unsigned int str_size;
    if (!enif_get_string_length(env, argv[0], &str_size, ERL_NIF_LATIN1)) {
        enif_fprintf(stderr, "Can't get string length %T\n", argv[0]);
        return enif_make_atom(env, "error");
    }
    char* func_name = (char*) enif_alloc(str_size + 1);
    if (enif_get_string(env, argv[0], func_name, str_size + 1, ERL_NIF_LATIN1) <= 0) {
        enif_fprintf(stderr, "Can't get string %T\n", argv[0]);
        return enif_make_atom(env, "error");
    }


    if (!enif_is_list(env, argv[1])) {
        return enif_make_atom(env, "error");
    }

    // unsigned int inputs_length;
    // if (!enif_get_list_length(env, argv[1], &inputs_length)) {
    //     return enif_make_atom(env, "error");
    // }
    if (!enif_is_list(env, argv[2])) {
        return enif_make_atom(env, "error");
    }

    unsigned int outputs_length;
    if (!enif_get_list_length(env, argv[2], &outputs_length)) {
        return enif_make_atom(env, "error");
    }
    // enif_fprintf(stderr, "Before init\n");

    TA_Initialize();  // Initialize the TA-Lib library
    TA_RetCode retCode;
    TA_RetCodeInfo info;
    // Get the function handle for RSI
    const TA_FuncHandle *funcHandle;
    retCode = TA_GetFuncHandle(func_name, &funcHandle);
    if (retCode != TA_SUCCESS) {
        enif_fprintf(stderr, "Error getting function handle: %d\n", retCode);
        TA_Shutdown();
        return enif_make_atom(env, "error");
    }

    // Allocate a parameter holder for the RSI function
    TA_ParamHolder *params;
    retCode = TA_ParamHolderAlloc(funcHandle, &params);
    if (retCode != TA_SUCCESS) {
        enif_fprintf(stderr, "Error allocating parameter holder: %d\n", retCode);
        TA_Shutdown();
        return enif_make_atom(env, "error");
    }



    ERL_NIF_TERM list_iter = argv[1];
    ERL_NIF_TERM head, tail;
    unsigned int req_idx = 0;
    unsigned int opt_idx = 0;
    // enif_fprintf(stderr, "Before loop\n");

    int endIdx = 0;

    while (enif_get_list_cell(env, list_iter, &head, &tail)) {

        int arity;
        const ERL_NIF_TERM* tuple_elems;
        if (!enif_get_tuple(env, head, &arity, &tuple_elems)) {
            return enif_make_atom(env, "error");
        }
        // enif_fprintf(stderr, "arity: %d\n", arity);

        unsigned int type;
        if (!enif_get_uint(env, tuple_elems[1], &type)) {
            return enif_make_atom(env, "error");
        }
        // enif_fprintf(stderr, "type: %d\n", type);

        unsigned int optional;
        if (!enif_get_uint(env, tuple_elems[2], &optional)) {
            return enif_make_atom(env, "error");
        }

        // enif_fprintf(stderr, "optional: %d\n", optional);

        switch (type) {

            case TYPE_INT:
                int int_value;
                if (!enif_get_int(env, tuple_elems[0], &int_value)) {
                    return enif_make_atom(env, "error");
                }

                // enif_fprintf(stdout, "Add value: %d on index: %d\n", int_value, opt_idx);
                retCode = optional ? TA_SetOptInputParamInteger(params, opt_idx, int_value) : TA_SetInputParamIntegerPtr(params, req_idx, &int_value);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting input parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }
                break;

            case TYPE_INT_ARRAY:
                ErlNifBinary int_values_binary;
                if (!enif_inspect_binary(env, tuple_elems[0], &int_values_binary)) {
                    return enif_make_atom(env, "error");
                }

                int *int_values = (int *)int_values_binary.data;

                // Set the input parameter (closing prices)
                retCode = optional ? TA_SetOptInputParamInteger(params, opt_idx, *int_values) : TA_SetInputParamIntegerPtr(params, req_idx, int_values);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting input parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }

                if (!optional && req_idx == 0) {
                    endIdx = int_values_binary.size / sizeof(int) - 1;
                }


                break;

            case TYPE_DOUBLE:
                double double_value;
                if (!enif_get_double(env, tuple_elems[0], &double_value)) {
                    return enif_make_atom(env, "error");
                }

                retCode = optional ? TA_SetOptInputParamReal(params, opt_idx, double_value) : TA_SetInputParamRealPtr(params, req_idx, &double_value);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting input parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }
                break;

            case TYPE_DOUBLE_ARRAY:
                ErlNifBinary double_values_binary;
                if (!enif_inspect_binary(env, tuple_elems[0], &double_values_binary)) {
                    return enif_make_atom(env, "error");
                }

                double *double_values = (double *)double_values_binary.data;
                // enif_fprintf(stdout, "Add double_values: on index: %d\n", req_idx);

                // Set the input parameter (closing prices)
                retCode = optional ? TA_SetOptInputParamReal(params, opt_idx, *double_values) : TA_SetInputParamRealPtr(params, req_idx, double_values);
                if (retCode != TA_SUCCESS) {
                    TA_SetRetCodeInfo(retCode, &info);
                    enif_fprintf(stderr, "Error setting double input parameter: %s (%d) 1st: %0.5f\n", info, retCode, double_values[4]);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }

                if (!optional && req_idx == 0) {
                    endIdx = double_values_binary.size / sizeof(double) - 1;
                    // enif_fprintf(stderr, "Set endIdx: %d, 5th: %0.5f\n", endIdx, double_values[4]);
                }

                
                break;
            case TYPE_PRICES:

                int prices_tuple_arity;
                const ERL_NIF_TERM* prices_tuple_elems;
                if (!enif_get_tuple(env, tuple_elems[0], &prices_tuple_arity, &prices_tuple_elems) || prices_tuple_arity != 6) {
                    return enif_make_atom(env, "error");
                }

                ErlNifBinary open_bin;
                ErlNifBinary high_bin;
                ErlNifBinary low_bin;
                ErlNifBinary close_bin;
                ErlNifBinary volume_bin;
                ErlNifBinary openInterest_bin;
                if (!enif_inspect_binary(env, prices_tuple_elems[0], &open_bin) ||
                    !enif_inspect_binary(env, prices_tuple_elems[1], &high_bin) ||
                    !enif_inspect_binary(env, prices_tuple_elems[2], &low_bin) ||
                    !enif_inspect_binary(env, prices_tuple_elems[3], &close_bin) ||
                    !enif_inspect_binary(env, prices_tuple_elems[4], &volume_bin) ||
                    !enif_inspect_binary(env, prices_tuple_elems[5], &openInterest_bin)) {
                    return enif_make_atom(env, "error");
                }

                // enif_fprintf(stdout, "Add prices: on index: %d\n", req_idx);

                retCode = TA_SetInputParamPricePtr( params, req_idx,
                                    open_bin.size > 1 ? (double *)open_bin.data : NULL,
                                    high_bin.size > 1 ? (double *)high_bin.data : NULL,
                                    low_bin.size > 1 ? (double *)low_bin.data : NULL,
                                    close_bin.size > 1 ? (double *)close_bin.data : NULL,
                                    volume_bin.size > 1 ? (double *)volume_bin.data : NULL,
                                    openInterest_bin.size > 1 ? (double *)openInterest_bin.data : NULL);

                if (retCode != TA_SUCCESS) {
                    TA_SetRetCodeInfo(retCode, &info);
                    enif_fprintf(stderr, "Error setting price input parameter: %s (%d) 1st: %0.5f\n", info, retCode, double_values[4]);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }

                if (!optional && req_idx == 0) {
                    if (open_bin.size > sizeof(double)) {endIdx = open_bin.size / sizeof(double) - 1;}
                    else if (high_bin.size > sizeof(double)) {endIdx = high_bin.size / sizeof(double) - 1;}
                    else if (low_bin.size > sizeof(double)) {endIdx = low_bin.size / sizeof(double) - 1;}
                    else if (close_bin.size > sizeof(double)) {endIdx = close_bin.size / sizeof(double) - 1;}
                    else if (volume_bin.size > sizeof(double)) {endIdx = volume_bin.size / sizeof(double) - 1;}
                    else if (openInterest_bin.size > sizeof(double)) {endIdx = openInterest_bin.size / sizeof(double) - 1;}
                }

                break;

            default:
                return enif_make_atom(env, "error");
        }

// TA_SetInputParamPricePtr()
        optional ? opt_idx++ : req_idx++;
        list_iter = tail;
    }

    int lookback;
    // Set the output parameter (pointer to store RSI values)
    retCode = TA_GetLookback(params, &lookback);
    if (retCode != TA_SUCCESS) {
        enif_fprintf(stderr,"Error getting lookback size: %d\n", retCode);
        TA_ParamHolderFree(params);
        TA_Shutdown();
        return enif_make_atom(env, "error");
    }

    // enif_fprintf(stderr,"lookback size: %d\n", lookback);

    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////
    ////////////////////// CALCULATE ACCORDING TO OUTPUT SIZE ////////////////////////

    ERL_NIF_TERM outputs = enif_make_list(env, 0);
    ERL_NIF_TERM out_list_iter = argv[2];
    ERL_NIF_TERM out_head, out_tail;
    unsigned int out_idx = 0;
    // enif_fprintf(stderr, "Before loop\n");


    while (enif_get_list_cell(env, out_list_iter, &out_head, &out_tail)) {
        unsigned int out_type;
        if (!enif_get_uint(env, out_head, &out_type)) {
            return enif_make_atom(env, "error");
        }

        ERL_NIF_TERM output;
        int out_count = endIdx - lookback + 1 > 0 ? endIdx - lookback + 1 : 0;
        switch (out_type) {

            case TYPE_INT:
                int* int_value = (int*)output;

                output = enif_make_int(env, *int_value);
                
                retCode = TA_SetOutputParamIntegerPtr(params, out_idx, int_value);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting output parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }
                break;

            case TYPE_INT_ARRAY:
                unsigned char* int_array_raw = enif_make_new_binary(env, out_count * sizeof(int), &output);
                int* int_array_data = (int*)int_array_raw; // Casting our data to int64 - our bar numbers / simple integers

                // Set the input parameter (closing prices)
                retCode = TA_SetOutputParamIntegerPtr(params, out_idx, int_array_data);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting output parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }
                break;

            case TYPE_DOUBLE:
                double* double_value = (double*)output;
                output = enif_make_double(env, *double_value);

                retCode = TA_SetOutputParamRealPtr(params, out_idx, double_value);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting output parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }
                break;

            case TYPE_DOUBLE_ARRAY:
                unsigned char* double_array_raw = enif_make_new_binary(env, out_count * sizeof(double), &output);
                double* double_array_data = (double*)double_array_raw; // Casting our data to int64 - our bar numbers / simple integers
                // enif_fprintf(stdout, "OUT double_value on index: %d\n", out_idx);
                // Set the input parameter (closing prices)
                retCode = TA_SetOutputParamRealPtr(params, out_idx, double_array_data);
                if (retCode != TA_SUCCESS) {
                    enif_fprintf(stderr, "Error setting output parameter: %d\n", retCode);
                    TA_ParamHolderFree(params);
                    TA_Shutdown();
                    return enif_make_atom(env, "error");
                }
                break;
            default:
                return enif_make_atom(env, "error");
        }

        outputs = enif_make_list_cell(env, output, outputs);
        // if (!) {
        //     return enif_make_atom(env, "error");
        // }



        out_idx++;
        out_list_iter = out_tail;

    }


    // ERL_NIF_TERM result_array_term;
    // unsigned char* result_array_out_data_raw = enif_make_new_binary(env, (endIdx - lookback + 1) * sizeof(double), &result_array_term);
    // double* result_array_data = (double*)result_array_out_data_raw; // Casting our data to int64 - our bar numbers / simple integers


    // retCode = TA_SetOutputParamRealPtr(params, 0, result_array_data);
    // if (retCode != TA_SUCCESS) {
    //     enif_fprintf(stderr,"Error setting output parameter: %d\n", retCode);
    //     TA_ParamHolderFree(params);
    //     TA_Shutdown();
    //     return enif_make_atom(env, "error");
    // }

    // Execute the RSI function
    int outBegIdx = 0;
    int outNbElement = 0;
    retCode = TA_CallFunc(params, 0, endIdx, &outBegIdx, &outNbElement);
    if (retCode != TA_SUCCESS) {
        enif_fprintf(stderr,"Error executing function: %d\n", retCode);
        TA_ParamHolderFree(params);
        TA_Shutdown();
        return enif_make_atom(env, "error");
    }

    // Display the RSI values
    // enif_fprintf(stderr,"outNbElement: %d, befIdex: %d\n", outNbElement, outBegIdx);
    // for (int i = 0; i < outNbElement; i++) {
    //     enif_fprintf(stderr,"Period %d: %f\n", outBegIdx + i, result_array_data[i]);
    // }

    // Clean up
    TA_ParamHolderFree(params);  // Free the parameter holder
    TA_Shutdown();               // Shutdown the TA-Lib library

    return enif_make_tuple2(env, outputs, enif_make_int(env, outNbElement == 0 ? endIdx + 1 : outBegIdx));
    // return enif_make_tuple2(env, outputs, enif_make_int(env, outBegIdx));

}


static ErlNifFunc nif_funcs[] = {
    {"call", 3, call, ERL_NIF_DIRTY_JOB_CPU_BOUND},
};

ERL_NIF_INIT(Elixir.ExTalib.Nif, nif_funcs, NULL, NULL, NULL, NULL)

