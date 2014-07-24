module SchoolStuff
  extend ActiveSupport::Concern

  included do 
    def is_school?
      category.code == "school"
    end

    def students_count
      students.count
    end

    def comments_count
      items.map(&:comments_count).reduce(:+)
    end

    def diagrams_count
      items.map(&:diagrams_count).reduce(:+)
    end

    def img_url
      ""
    end

    def fill_rate
      rand(100)/100.0
    end
  end

  module ClassMethods
  end

end
