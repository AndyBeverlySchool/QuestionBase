require 'data_mapper'
require 'dm-validations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/questions.db")

class Question
  include DataMapper::Resource

  property :id,         Serial
  property :stem,       Text,         :required => true
  has n, :tags
  has n, :comments
  has n, :choices
  has n, :comments
  has n, :feedbacks
end

class Choice
  include DataMapper::Resource
  belongs_to :question

  property :id,          Serial
  property :content,     Text,        :required => true
  property :truth,       Boolean,     :required => true
end

class Comment
  include DataMapper::Resource
  belongs_to :question

  property :id,          Serial
  property :content,     Text,        :required => true
  property :author,      Text,        :required => true
end

class Feedback
  include DataMapper::Resource

  belongs_to :question
  property :id,          Serial
  property :content,     Text,        :required => true
end

class Tag
  include DataMapper::Resource

  belongs_to :question
  property :id,          Serial
  property :content,     Text,        :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!
