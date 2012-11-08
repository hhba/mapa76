class Tweet
  include Mongoid::Document

  field :contributors, :field => String
  field :coordinates, :field => String
  field :text, :field => String
  field :in_reply_to_status_id_str, :field => String
  field :favorited, :field => String
  field :id_str, :field => String
  field :in_reply_to_user_id_str, :field => String
  field :source, :field => String
  field :truncated, :field => String
  field :geo, :field => String
  field :retweeted, :field => String
  field :entities, :type => Hash 
  field :retweeted_status, :type => Hash 
  field :place, :field => String
  field :user, :type => Hash 
  field :retweet_count, :field => Integer
  field :in_reply_to_screen_name, :field => String
  field :in_reply_to_user_id, :field => String
  field :in_reply_to_status_id, :field => String

end