# let's get down
require 'sinatra'
require "sinatra/flash"
require_relative 'data_map'
require 'haml'

enable :sessions, :logging

get '/' do
  "Hello."
end

get '/show/:id' do
  q = Question.get(params["id"])
  if (q) then
    haml :show, :locals => {:q => q}
  else
    haml "%H1 No data found"
  end
end

get '/add' do
  haml :add
end

# Question, stem ...
# Choices (x4), each(content, truth)
# Comment, content, author
# Feedback, content
#tag, content
post '/add' do
  tags = []
  params["tags"].split(",").each { |s|
    tags << Tag.new(:content => s.strip)
  }
  feedback = Feedback.new(:content => params["feedback"])
  comment = Comment.new(:content => params["comment"], :author => params["author"])
  choices = []
  4.times { |i|
    tci = params["truth_choice#{i}"]
    tci === "on" ? (tci = true) : (tci = false)
    choices << Choice.new(:content => params["content_choice#{i}"],
                          :truth => tci)
    logger.info "Choice: #{choices[i].inspect}"
  }
  q = Question.new(
    :stem     =>      params['stem'],
    :choices  =>      choices,
    :tags     =>      tags
  )
  q.comments   <<   comment
  q.feedbacks  <<   feedback
  question_write q
end

def question_write q
  # Validation... todo: move this elsewhere / take a more idiomatic approach
  c = 0
  {"choices" => q.choices, "tags" => q.tags, "feedbacks" => q.feedbacks, "comments" => q.comments}.each do |key, value|
    value.each_with_index do |v, i|
      v.save
      v.errors.each do |e|
        flash.now[key + c.to_s] = "#{key}: #{e}"
        c+=1
      end
    end
  end
  flash.now[:choices] = "All 4 choices are required!" if q.choices.count != 4
  q.errors.each_with_index do |e, i|
    flash.now["question#{i}"] = e
  end
  logger.info "Question: " + q.inspect
  if (q.save && flash.now.empty?) then
      redirect to("/show/#{q.id}")
  else
    haml "%H1 Question could not be saved!\n%p\n  =styled_flash"
  end
end
