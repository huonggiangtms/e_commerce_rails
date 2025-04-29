module ApplicationHelper
  def formatted_datetime(datetime)
    datetime.strftime("%b %d, %Y %H:%M")
  end
end
