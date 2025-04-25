defmodule Qart.BSV do
  @moduledoc """
  Module to create a dummy unsigned BSV transaction embedding content.
  """
  alias BSV.Contract.{P2PKH, OpReturn}

  def print_output_script(chunks) do
    # Parse the script hex into a list of chunks.
    # Depending on your bsv-ex version, you might use `parse/1` or `from_hex/1`
    # Here we assume it returns something like: [{:opcode, :OP_DUP}, {:data, <<...>>}, ...]
    # case BSV.Script.from_binary(script_hex, encoding: :hex) do
      # {:ok, chunks} ->
      z = chunks
      |> Enum.map(&chunk_to_string/1)
      |> Enum.join(" ")
      z
      # {:error, reason} ->
      #   IO.puts("Error parsing script: #{inspect(reason)}")
    # end
  end

  defp chunk_to_string(opcode) when is_atom(opcode) do
    # Convert the opcode to its string name.
    Atom.to_string(opcode)
  end

  defp chunk_to_string(data) when is_binary(data) do
    # If the data is printable, show it as is.
    # Otherwise, display it as a hex string.
    if String.printable?(data) do
      data
    else
      "0x" <> Base.encode16(data)
    end
  end


  def build_inputs_tx(outputs, keypair) do
    built_outputs = outputs |> Enum.map(fn input -> OpReturn.lock(0, %{data: input.content}) end)

    # Create a new transaction and add an output with the OP_RETURN script.
    # Here, the output value is set to 0 since OP_RETURN outputs don't carry spendable bitcoin.
    utxo_1 = BSV.UTXO.from_params!(%{
      "txid" => "5e3014372338f079f005eedc85359e4d96b8440e7dbeb8c35c4182e0c19a1a12",
      "vout" => 0,
      "satoshis" => 11000,
      "script" => "76a914538fd179c8be0f289c730e33b5f6a3541be9668f88ac"
    })

    utxo_2 = BSV.UTXO.from_params!(%{
      "txid" => "5e3014372338f079f005eedc85359e4d96b8440e7dbeb8c35c4182e0c19a1a12",
      "vout" => 1,
      "satoshis" => 11000,
      "script" => "76a914538fd179c8be0f289c730e33b5f6a3541be9668f88ac"
    })

    builder = %BSV.TxBuilder{
      inputs: [
        P2PKH.unlock(utxo_1, %{keypair: keypair}),
        P2PKH.unlock(utxo_2, %{keypair: keypair})
      ],
      outputs: built_outputs
    }

    BSV.TxBuilder.to_tx(builder)
  end

  defmodule ScriptPatterns do
    @doc "Returns true if the chunks match a P2PKH pattern"
    def is_p2pkh?(chunks) do
      case chunks do
        [
          :OP_DUP,
          :OP_HASH160,
          hash,
          :OP_EQUALVERIFY,
          :OP_CHECKSIG
        ] when byte_size(hash) == 20 ->
          true
        _ ->
          false
      end
    end

    @doc "Returns true if the chunks match a typical P2MS (multisig) pattern"
    def is_p2ms?(chunks) do
      # Example pattern: [required, pubkey pushes..., total, OP_CHECKMULTISIG]
      # Here you’d extract the numeric values from the opcodes and compare against the number of pubkey pushes.
      case chunks do
        [{:opcode, req}, rest] ->
          # This is a simplified check. You need to decode opcodes (e.g., :OP_2 -> 2) and then count the pubkeys.
          if Enum.any?(rest, fn
              {:opcode, :OP_CHECKMULTISIG} -> true
              _ -> false
            end) do
            # Implement further checking here...
            true
          else
            false
          end
        _ ->
          false
      end
    end

    @doc "Returns true if the chunks appear to be a 1satOrdinal output"
    def is_1sat_ordinal?(chunks) do
      case chunks do
        [{:opcode, :OP_RETURN}, {:data, payload} | _rest] ->
          # Check for a known protocol prefix (adjust this prefix as needed)
          String.starts_with?(payload, "ord")
        _ ->
          false
      end
    end

    def identify(script = %BSV.Script{}) when is_list(script.chunks) do
      cond do
        is_p2pkh?(script.chunks) -> :p2pkh
        is_2sat_ordinal?(script.chunks) -> :one_sat_ordinal
        is_op_return?(script.chunks) -> :op_return
        # match_p2wpkh?(script.chunks) -> :p2wpkh
        # match_p2wsh?(script.chunks) -> :p2wsh
        # match_op_return?(script.chunks) -> :op_return

        true -> :unknown # :unknown_script_type
      end
    end

    def identify!(chunks) do
      Qart.debug(chunks)
    end

    def is_op_return?(chunks) do
      case chunks do
        [
          :OP_FALSE,
          :OP_RETURN
          |
          payload
        ] ->
          {:ok, :op_return, %{
            payload: payload
          }}

        _ ->
          false
      end
    end

    def is_2sat_ordinal?(chunks) do
      case chunks do
        [
          :OP_DUP,
          :OP_HASH160,
          hash,
          :OP_EQUALVERIFY,
          :OP_CHECKSIG,
          :OP_FALSE,
          :OP_IF,
          "ord",
          :OP_1,
          file_format,
          :OP_FALSE,
          payload,
          :OP_ENDIF,
          :OP_RETURN,
          address_to,
          "SET",
          "app",
          "ZoideNFT",
          "type",
          "ord",
          "subType",
          "collectionItem",
          "subTypeData",
          json
          | _rest
        ] ->
        # [{:opcode, :OP_RETURN}, {:data, payload} | _rest] ->
          # Check for a known protocol prefix (adjust this prefix as needed)
          # String.starts_with?(payload, "ord")
          {:ok, :one_sat, %{
            payload: payload,
            payload_base64: payload |> Base.encode64,
            address_to: address_to,
            json: json
          }}

        _ ->
          false # {:ok, %{json: "{}", payload: nil, payload_base64: nil }}
      end
    end
  end

  def standard_transaction_with_change_outputs(to_address, change_address, opreturn_array) do
    [
      P2PKH.lock(10000, %{address: to_address}),
      P2PKH.lock(10000, %{address: change_address}),
      OpReturn.lock(0, %{data: opreturn_array})
    ]
  end

end
