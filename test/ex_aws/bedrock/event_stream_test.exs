defmodule ExAws.Bedrock.EventStreamTest do
  use ExUnit.Case

  alias ExAws.Bedrock.EventStream

  @uint32_size 4
  @checksum_size 4
  @prelude_length @uint32_size * 3
  @message_overhead @prelude_length + @checksum_size

  describe "decode_chunk/1" do
    test "should decode single chunk response", %{chunk: chunk} do
      assert [{:chunk, %{"outputText" => output_text}}] = EventStream.decode_chunk(chunk)
      assert String.contains?(output_text, "Elixir")
    end

    test "should decode multiple chunks in single response", %{multipart_chunk: multipart_chunk} do
      assert [{:chunk, %{"type" => _}}, {:chunk, %{"type" => _}}] =
               EventStream.decode_chunk(multipart_chunk)
    end

    test "should handle invalid prelude checksum", %{chunk_with_invalid_prelude_checksum: chunk} do
      assert [{:bad_chunk, ^chunk, :invalid_prelude_checksum}] =
               EventStream.decode_chunk(chunk)
    end

    test "should handle invalid message checksum", %{chunk_with_invalid_message_checksum: chunk} do
      assert [{:bad_chunk, ^chunk, :invalid_message_checksum}] =
               EventStream.decode_chunk(chunk)
    end

    test "should handle incomplete chunk", %{incomplete_chunk: chunk} do
      assert [{:bad_chunk, ^chunk, :invalid_chunk}] = EventStream.decode_chunk(chunk)
    end
  end

  setup_all do
    # Claude 3.5 Sonnet Multi-Chunk response
    multipart_chunk =
      <<0, 0, 1, 209, 0, 0, 0, 75, 251, 229, 194, 61, 11, 58, 101, 118, 101, 110, 116, 45, 116,
        121, 112, 101, 7, 0, 5, 99, 104, 117, 110, 107, 13, 58, 99, 111, 110, 116, 101, 110, 116,
        45, 116, 121, 112, 101, 7, 0, 16, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 47,
        106, 115, 111, 110, 13, 58, 109, 101, 115, 115, 97, 103, 101, 45, 116, 121, 112, 101, 7,
        0, 5, 101, 118, 101, 110, 116, 123, 34, 98, 121, 116, 101, 115, 34, 58, 34, 101, 121, 74,
        48, 101, 88, 66, 108, 73, 106, 111, 105, 98, 87, 86, 122, 99, 50, 70, 110, 90, 86, 57,
        122, 100, 71, 70, 121, 100, 67, 73, 115, 73, 109, 49, 108, 99, 51, 78, 104, 90, 50, 85,
        105, 79, 110, 115, 105, 97, 87, 81, 105, 79, 105, 74, 116, 99, 50, 100, 102, 89, 109, 82,
        121, 97, 49, 56, 119, 77, 85, 53, 113, 85, 68, 70, 119, 78, 106, 74, 50, 83, 50, 104, 54,
        99, 108, 107, 49, 100, 84, 100, 88, 97, 86, 78, 121, 100, 109, 111, 105, 76, 67, 74, 48,
        101, 88, 66, 108, 73, 106, 111, 105, 98, 87, 86, 122, 99, 50, 70, 110, 90, 83, 73, 115,
        73, 110, 74, 118, 98, 71, 85, 105, 79, 105, 74, 104, 99, 51, 78, 112, 99, 51, 82, 104, 98,
        110, 81, 105, 76, 67, 74, 116, 98, 50, 82, 108, 98, 67, 73, 54, 73, 109, 78, 115, 89, 88,
        86, 107, 90, 83, 48, 122, 76, 84, 85, 116, 99, 50, 57, 117, 98, 109, 86, 48, 76, 84, 73,
        119, 77, 106, 81, 119, 78, 106, 73, 119, 73, 105, 119, 105, 89, 50, 57, 117, 100, 71, 86,
        117, 100, 67, 73, 54, 87, 49, 48, 115, 73, 110, 78, 48, 98, 51, 66, 102, 99, 109, 86, 104,
        99, 50, 57, 117, 73, 106, 112, 117, 100, 87, 120, 115, 76, 67, 74, 122, 100, 71, 57, 119,
        88, 51, 78, 108, 99, 88, 86, 108, 98, 109, 78, 108, 73, 106, 112, 117, 100, 87, 120, 115,
        76, 67, 74, 49, 99, 50, 70, 110, 90, 83, 73, 54, 101, 121, 74, 112, 98, 110, 66, 49, 100,
        70, 57, 48, 98, 50, 116, 108, 98, 110, 77, 105, 79, 106, 69, 50, 76, 67, 74, 118, 100, 88,
        82, 119, 100, 88, 82, 102, 100, 71, 57, 114, 90, 87, 53, 122, 73, 106, 111, 120, 102, 88,
        49, 57, 34, 44, 34, 112, 34, 58, 34, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107,
        108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 34, 125, 242, 141, 159, 168,
        0, 0, 0, 235, 0, 0, 0, 75, 219, 40, 177, 191, 11, 58, 101, 118, 101, 110, 116, 45, 116,
        121, 112, 101, 7, 0, 5, 99, 104, 117, 110, 107, 13, 58, 99, 111, 110, 116, 101, 110, 116,
        45, 116, 121, 112, 101, 7, 0, 16, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 47,
        106, 115, 111, 110, 13, 58, 109, 101, 115, 115, 97, 103, 101, 45, 116, 121, 112, 101, 7,
        0, 5, 101, 118, 101, 110, 116, 123, 34, 98, 121, 116, 101, 115, 34, 58, 34, 101, 121, 74,
        48, 101, 88, 66, 108, 73, 106, 111, 105, 89, 50, 57, 117, 100, 71, 86, 117, 100, 70, 57,
        105, 98, 71, 57, 106, 97, 49, 57, 122, 100, 71, 70, 121, 100, 67, 73, 115, 73, 109, 108,
        117, 90, 71, 86, 52, 73, 106, 111, 119, 76, 67, 74, 106, 98, 50, 53, 48, 90, 87, 53, 48,
        88, 50, 74, 115, 98, 50, 78, 114, 73, 106, 112, 55, 73, 110, 82, 53, 99, 71, 85, 105, 79,
        105, 74, 48, 90, 88, 104, 48, 73, 105, 119, 105, 100, 71, 86, 52, 100, 67, 73, 54, 73,
        105, 74, 57, 102, 81, 61, 61, 34, 44, 34, 112, 34, 58, 34, 97, 98, 99, 100, 101, 102, 103,
        104, 105, 106, 107, 108, 109, 34, 125, 183, 31, 201, 1>>

    chunk =
      <<0, 0, 2, 211, 0, 0, 0, 75, 7, 177, 227, 243, 11, 58, 101, 118, 101, 110, 116, 45, 116,
        121, 112, 101, 7, 0, 5, 99, 104, 117, 110, 107, 13, 58, 99, 111, 110, 116, 101, 110, 116,
        45, 116, 121, 112, 101, 7, 0, 16, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 47,
        106, 115, 111, 110, 13, 58, 109, 101, 115, 115, 97, 103, 101, 45, 116, 121, 112, 101, 7,
        0, 5, 101, 118, 101, 110, 116, 123, 34, 98, 121, 116, 101, 115, 34, 58, 34, 101, 121, 74,
        118, 100, 88, 82, 119, 100, 88, 82, 85, 90, 88, 104, 48, 73, 106, 111, 105, 88, 71, 53,
        70, 98, 71, 108, 52, 97, 88, 73, 103, 97, 88, 77, 103, 89, 83, 66, 119, 99, 109, 57, 110,
        99, 109, 70, 116, 98, 87, 108, 117, 90, 121, 66, 115, 89, 87, 53, 110, 100, 87, 70, 110,
        90, 83, 66, 48, 97, 71, 70, 48, 73, 71, 70, 112, 98, 88, 77, 103, 100, 71, 56, 103, 97,
        87, 49, 119, 99, 109, 57, 50, 90, 83, 66, 48, 97, 71, 85, 103, 99, 72, 74, 118, 90, 72,
        86, 106, 100, 71, 108, 50, 97, 88, 82, 53, 73, 71, 70, 117, 90, 67, 66, 122, 89, 50, 70,
        115, 89, 87, 74, 112, 98, 71, 108, 48, 101, 83, 66, 118, 90, 105, 66, 122, 98, 50, 90, 48,
        100, 50, 70, 121, 90, 83, 66, 107, 90, 88, 90, 108, 98, 71, 57, 119, 98, 87, 86, 117, 100,
        67, 66, 105, 101, 83, 66, 119, 99, 109, 57, 50, 97, 87, 82, 112, 98, 109, 99, 103, 89, 83,
        66, 106, 98, 50, 53, 106, 97, 88, 78, 108, 73, 71, 70, 117, 90, 67, 66, 108, 101, 72, 66,
        121, 90, 88, 78, 122, 97, 88, 90, 108, 73, 72, 78, 53, 98, 110, 82, 104, 101, 67, 119,
        103, 99, 71, 57, 51, 90, 88, 74, 109, 100, 87, 119, 103, 90, 109, 86, 104, 100, 72, 86,
        121, 90, 88, 77, 115, 73, 71, 70, 117, 90, 67, 66, 104, 73, 72, 74, 118, 89, 110, 86, 122,
        100, 67, 66, 108, 89, 50, 57, 122, 101, 88, 78, 48, 90, 87, 48, 103, 98, 50, 89, 103, 98,
        71, 108, 105, 99, 109, 70, 121, 97, 87, 86, 122, 73, 71, 70, 117, 90, 67, 66, 48, 98, 50,
        57, 115, 99, 121, 52, 105, 76, 67, 74, 112, 98, 109, 82, 108, 101, 67, 73, 54, 77, 67,
        119, 105, 100, 71, 57, 48, 89, 87, 120, 80, 100, 88, 82, 119, 100, 88, 82, 85, 90, 88,
        104, 48, 86, 71, 57, 114, 90, 87, 53, 68, 98, 51, 86, 117, 100, 67, 73, 54, 78, 68, 65,
        115, 73, 109, 78, 118, 98, 88, 66, 115, 90, 88, 82, 112, 98, 50, 53, 83, 90, 87, 70, 122,
        98, 50, 52, 105, 79, 105, 74, 71, 83, 85, 53, 74, 85, 48, 103, 105, 76, 67, 74, 112, 98,
        110, 66, 49, 100, 70, 82, 108, 101, 72, 82, 85, 98, 50, 116, 108, 98, 107, 78, 118, 100,
        87, 53, 48, 73, 106, 111, 120, 77, 83, 119, 105, 89, 87, 49, 104, 101, 109, 57, 117, 76,
        87, 74, 108, 90, 72, 74, 118, 89, 50, 115, 116, 97, 87, 53, 50, 98, 50, 78, 104, 100, 71,
        108, 118, 98, 107, 49, 108, 100, 72, 74, 112, 89, 51, 77, 105, 79, 110, 115, 105, 97, 87,
        53, 119, 100, 88, 82, 85, 98, 50, 116, 108, 98, 107, 78, 118, 100, 87, 53, 48, 73, 106,
        111, 120, 77, 83, 119, 105, 98, 51, 86, 48, 99, 72, 86, 48, 86, 71, 57, 114, 90, 87, 53,
        68, 98, 51, 86, 117, 100, 67, 73, 54, 78, 68, 65, 115, 73, 109, 108, 117, 100, 109, 57,
        106, 89, 88, 82, 112, 98, 50, 53, 77, 89, 88, 82, 108, 98, 109, 78, 53, 73, 106, 111, 120,
        78, 106, 103, 49, 76, 67, 74, 109, 97, 88, 74, 122, 100, 69, 74, 53, 100, 71, 86, 77, 89,
        88, 82, 108, 98, 109, 78, 53, 73, 106, 111, 120, 78, 106, 103, 49, 102, 88, 48, 61, 34,
        125, 72, 100, 27, 122>>

    # Create a chunk with an invalid prelude checksum
    chunk_with_invalid_prelude_checksum = alter_prelude_checksum(chunk)

    # Create a chunk with an invalid message checksum
    chunk_with_invalid_message_checksum = alter_message_checksum(chunk)

    # Create an incomplete chunk by truncating the valid chunk
    incomplete_chunk = binary_part(chunk, 0, byte_size(chunk) - 10)

    %{
      chunk: chunk,
      multipart_chunk: multipart_chunk,
      chunk_with_invalid_prelude_checksum: chunk_with_invalid_prelude_checksum,
      chunk_with_invalid_message_checksum: chunk_with_invalid_message_checksum,
      incomplete_chunk: incomplete_chunk
    }
  end

  defp alter_prelude_checksum(chunk) do
    # Modify the prelude checksum to be invalid
    <<message_total_length::unsigned-32, headers_length::unsigned-32,
      _prelude_checksum::unsigned-32, rest::binary>> = chunk

    invalid_prelude_checksum = 0

    <<message_total_length::unsigned-32, headers_length::unsigned-32,
      invalid_prelude_checksum::unsigned-32, rest::binary>>
  end

  defp alter_message_checksum(chunk) do
    # Parse the chunk to extract message parts
    <<message_total_length::unsigned-32, headers_length::unsigned-32,
      prelude_checksum::unsigned-32, rest::binary>> = chunk

    message_length = message_total_length - @message_overhead
    body_length = message_length - headers_length

    <<headers::binary-size(headers_length), body::binary-size(body_length),
      _message_checksum::unsigned-32>> = rest

    invalid_message_checksum = 0

    <<message_total_length::unsigned-32, headers_length::unsigned-32,
      prelude_checksum::unsigned-32, headers::binary, body::binary,
      invalid_message_checksum::unsigned-32>>
  end
end
