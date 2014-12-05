defmodule Runner do

    def main(args) do
        case OptionParser.parse(args) do
            {_, [url], []} -> DownloadEx.start_download(url)
        end
    end

end
