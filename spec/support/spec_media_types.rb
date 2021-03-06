class Person < Praxis::MediaType
  identifier "application/vnd.acme.person"

  attributes do
    attribute :id, Integer
    attribute :name, String, example: /[:name:]/
    attribute :href, String, example: proc { |person| "/people/#{person.id}" }
    attribute :links, Attributor::Collection.of(String),
      description: 'Here to ensure an explicit links attribute works'
      
  end

  view :default do
    attribute :id
    attribute :name
    attribute :links
  end

  view :link do
    attribute :id
    attribute :name
    attribute :href
  end

  class CollectionSummary < Praxis::MediaType
    attributes do
      attribute :href, String
      attribute :size, Integer
    end

    view :link do
      attribute :href
      attribute :size
    end

    view :default do
      attribute :href
    end

  end
end


class Address < Praxis::MediaType
  identifier 'application/json'

  description 'Address MediaType'
  display_name 'The Address'

  attributes do
    attribute :id, Integer
    attribute :name, String

    attribute :owner, Person
    attribute :custodian, Person

    attribute :residents, Praxis::Collection.of(Person)
    attribute :residents_summary, Person::CollectionSummary

    links do
      link :owner
      link :super, Person, using: :manager
      link :caretaker, using: :custodian
      link :residents, using: :residents_summary
    end

  end

  view :default do
    attribute :id
    attribute :name
    attribute :owner

    attribute :links
  end

  view :link do
    attribute :id
    attribute :name
  end

end




class Blog < Praxis::MediaType
  identifier 'application/vnd.bloggy.blog'
  description "A Bloggy Blog"

  attributes do
    attribute :id, Integer,
      description: 'Unique identifier'
    attribute :name, String,
      description: 'Short name'
    attribute :href, String,
      example: proc {|o,ctx| "/api/v1.0/blogs/#{o.id}"},
      description: 'Href for use with this API'
    attribute :description, String,
      description: 'Longer description'
    attribute :url, String,
      example: proc {|o,ctx| "example.com/blogs/#{o.id}"},
      description: 'URL for a web browser'

    attribute :timestamps do
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end

    attribute :tags, Attributor::Collection.of(String),
      description: 'Array of tags'

    attribute :recent_posts, Praxis::Collection.of(Post),
      description: 'Array of recent related Post resources'
    attribute :owner, User,
      description: 'Related User resource'

    attribute :posts_summary, Post::CollectionSummary,
      example: proc { |blog,ctx| Post::CollectionSummary.example(ctx, href: "#{blog.href}/posts") },
      description: "Summary of information from related Post resources"

    links do
      link :posts, using: :posts_summary
      link :owner
    end
  end

  view :default do
    attribute :id
    attribute :href
    attribute :name
    attribute :description
    attribute :url
    attribute :timestamps

    attribute :owner
    attribute :links
  end

  view :overview do
    attribute :id
    attribute :name
    attribute :description
  end

  view :link do
    attribute :href
  end

end


class Post < Praxis::MediaType
  identifier 'application/vnd.bloggy.post'

  description 'A Post in Bloggy'

  attributes do
    attribute :id, Integer,
      description: 'Unique identifier'
    attribute :href, String,
      example: proc {|o,ctx| "/api/v1.0/posts/#{o.id}"},
      description: 'Href for use with this API'

    attribute :title, String,
      example: /\w+/
    attribute :content, String,
      example: /[:sentence:]{4,5}/
    attribute :url, String,
      description: 'URL for a web browser',
      example: proc {|o,ctx| "example.com/posts/#{o.id}"}

    attribute :author, User,
      description: 'Related User resource'
    attribute :blog, Blog,
      description: 'Related Blog resource'

    attribute :followup_posts, Attributor::Collection.of(Post)

    attribute :timestamps do
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end

    links do
      link :author
      link :blog
    end
  end

  view :default do
    attribute :id
    attribute :href

    attribute :title
    attribute :content
    attribute :url
    attribute :author

    attribute :timestamps
    attribute :links
  end

  view :link do
    attribute :href
  end


  class CollectionSummary < Praxis::MediaType
    attributes do
      attribute :href, String
      attribute :count, Integer
    end

    view :link do
      attribute :href
    end
  end
end


class User < Praxis::MediaType
  identifier 'application/vnd.bloggy.user'

  attributes do
    attribute :id, Integer
    attribute :href, String,
      example: proc {|o,ctx| "/api/v1.0/users/#{o.id}"}

    attribute :first, String, example: /[:first_name:]/
    attribute :last, String, example: /[:last_name:]/
    attribute :posts, Attributor::Collection.of(Post)

    attribute :post_matrix, Attributor::Collection.of(Attributor::Collection.of(Post)),
      description: 'matrix of posts with some row and some column axes that make sense'
    attribute :daily_posts, Attributor::Collection.of(Attributor::Struct) do
      attribute :day, String
      attribute :posts, Attributor::Collection.of(Post)
    end

    attribute :primary_blog, Blog

    attribute :timestamps do
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
    end

    attribute :posts_summary, Post::CollectionSummary,
      example: proc { |user,ctx| Post::CollectionSummary.example(ctx, href: "#{user.href}/posts") }

    links do
      link :posts, using: :posts_summary
      link :primary_blog
    end

  end

  view :default do
    attribute :id
    attribute :href

    attribute :first
    attribute :last

    attribute :links
  end

  view :extended do
    attribute :id
    attribute :href

    attribute :first
    attribute :last
    attribute :primary_blog, view: :overview

    attribute :links
  end

  view :with_post_links do
    attribute :id
    attribute :posts, view: :link
  end

  view :link do
    attribute :href
  end

  view :summary do
    attribute :links
  end
end
