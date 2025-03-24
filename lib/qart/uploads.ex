defmodule Qart.Uploads do
  alias Qart.Uploads.ImageProcessor

  @upload_dir "priv/static/uploads"

  def save_upload(%Plug.Upload{filename: filename, path: tmp_path}) do
    File.mkdir_p!(@upload_dir)  # Ensure upload directory exists

    new_path = Path.join(@upload_dir, filename)
    File.cp!(tmp_path, new_path)  # Save original file

    # ✅ Process and generate multiple sizes
    ImageProcessor.process_image(new_path, @upload_dir)

    {:ok, filename}
  end
end
