require 'compote/pipeline/task/update_comic_list'
require 'compote/pipeline/task/update_source_bodies'
require 'compote/pipeline/task/update_books_from_sources'

module Compote
  module Pipeline
    class DailyUpdate

      def start(month_ago:0)
        task = Task::UpdateComicList.new
        task.start month_ago

        task = Task::UpdateSourceBodies.new
        updated_source_ids = task.start month_ago

        task = Task::UpdateBooksFromSources.new
        task.start updated_source_ids
      end
    end
  end
end
