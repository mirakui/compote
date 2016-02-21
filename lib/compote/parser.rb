module Compote
  class Parser
    def extract_isbns_from_comic_list_html(page)
      page.scan(/>\s*(9784\d+)\s*</).map {|m| m[0] }
    end
  end
end
