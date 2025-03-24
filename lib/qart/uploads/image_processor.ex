defmodule Qart.Uploads.ImageProcessor do
  import Mogrify

  @output_sizes %{
    small_square: {200, 200},  # 1:1
    card: {800, 400},          # 2:1
    post: {1200, 900},         # 4:3
    full: :original            # Keep full-size
  }

  @doc "Processes an uploaded image into multiple sizes"
  def process_image(original_path, upload_dir) do
    Enum.each(@output_sizes, fn {version, size} ->
      resized_path = Path.join(upload_dir, "#{version}_#{Path.basename(original_path)}")

      if size == :original do
        File.cp!(original_path, resized_path)  # ✅ Save full-size version
      else
        resize_image(original_path, resized_path, size)
      end
    end)
  end

  defp resize_image(input_path, output_path, {width, height}) do
    input_path
    |> Mogrify.open()
    |> Mogrify.resize("#{width}x#{height}!")
    |> Mogrify.save(path: output_path)
  end
end
