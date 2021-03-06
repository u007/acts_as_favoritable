require 'test_helper'

class ActsAsFavoritableTest < ActiveSupport::TestCase
  setup do
    3.times do |i|
      User.create(name: "user#{i}")
    end
    3.times do |i|
      Post.create(title: "title #{i}", body: "body #{i}")
    end
    3.times do |i|
      Article.create(title: "title #{i}", body: "body #{i}")
    end
  end

  test "module 'ActsAsFavoritable' is existed" do
    assert_kind_of Module, ActsAsFavoritable
  end

  test "method 'acts_as_favoritable' is available" do
    assert Post.respond_to? :acts_as_favoritable
    post = Post.first
    assert_equal 0, post.favorites.size
  end

  test "method 'acts_as_favoriter' is available" do
    assert User.respond_to? :acts_as_favoriter
    user = User.first
    assert_equal 0, user.favorites.size
    assert_equal 0, user.favorited_posts.size

    post = Post.first
    user.favorites.create(favoritable: post)
    assert_equal 1, user.favorites.size
    assert_equal 1, user.favorited_posts.size
  end

  test "method family 'favorited...' works" do
    user = User.first
    post = Post.first
    article = Article.first

    assert_equal 0, user.favorited_posts.size

    user.favorited_posts << post
    assert_equal 1, user.favorites.size
    assert_equal 1, user.favorited_posts.size

    assert user.favorited_posts.include? post

    user.favorited_posts.delete post
    assert_equal 0, user.favorites.size
    assert_equal 0, user.favorited_posts.size

    assert !(user.favorited_articles.include? article)
    user.favorited_articles << article
    assert user.favorited_articles.include? article
    user.favorited_articles.delete article
    assert !(user.favorited_articles.include? article)
  end

  test "method family 'favoriting...' works" do
    user = User.first
    post = Post.first

    assert_equal 0, post.favoriting_users.size

    post.favoriting_users << user
    assert_equal 1, post.favorites.size
    assert_equal 1, post.favoriting_users.size

    assert post.favoriting_users.include? user

    post.favoriting_users.delete user
    assert_equal 0, post.favorites.size
    assert_equal 0, post.favoriting_users.size
  end

  test "methods 'favorite/unfavorite/favoriting?' are available" do
    user = User.first
    assert user.respond_to? :favoriting?
    assert user.respond_to? :favorite
    assert user.respond_to? :unfavorite
  end

  test "methods 'favorite/unfavorite/favoriting?' work" do
    post = Post.first
    user = User.first
    article = Article.first

    assert !user.favoriting?(post)
    assert_equal 0, Favorite.count
    assert_equal 0, user.favorited_posts.size
    assert_equal 0, user.favorited_articles.size

    user.favorite(post)
    assert user.favoriting?(post)
    assert_equal 1, Favorite.count
    assert_equal 1, user.favorited_posts.size
    assert_equal 0, user.favorited_articles.size

    user.favorite(article)
    assert user.favoriting?(article)
    assert_equal 2, Favorite.count
    assert_equal 1, user.favorited_posts.size
    assert_equal 1, user.favorited_articles.size

    user.unfavorite(post)
    assert !user.favoriting?(post)
    assert_equal 1, Favorite.count
    assert_equal 0, user.favorited_posts.size
    assert_equal 1, user.favorited_articles.size

    user.unfavorite(article)
    assert !user.favoriting?(article)
    assert_equal 0, Favorite.count
    assert_equal 0, user.favorited_posts.size
    assert_equal 0, user.favorited_articles.size
  end

  test "method 'favorite_by' is available" do
    post = Post.first
    assert post.respond_to? :favorite_by
  end

  test "methods 'favorite_by/unfavorite_by/favoriting_by?' work" do
    post = Post.first
    user = User.first
    article = Article.first

    assert !post.favoriting_by?(user)
    assert !article.favoriting_by?(user)
    assert_equal 0, Favorite.count
    assert_equal 0, user.favorited_posts.size
    assert_equal 0, user.favorited_articles.size

    post.favorite_by(user)
    assert post.favoriting_by?(user)
    assert_equal 1, Favorite.count
    assert_equal 1, user.favorited_posts.size
    assert_equal 0, user.favorited_articles.size

    article.favorite_by(user)
    assert article.favoriting_by?(user)
    assert_equal 2, Favorite.count
    assert_equal 1, user.favorited_posts.size
    assert_equal 1, user.favorited_articles.size

    post.unfavorite_by(user)
    assert !post.favoriting_by?(user)
    assert_equal 1, Favorite.count
    assert_equal 0, user.favorited_posts.size
    assert_equal 1, user.favorited_articles.size

    article.unfavorite_by(user)
    assert !article.favoriting_by?(user)
    assert_equal 0, Favorite.count
    assert_equal 0, user.favorited_posts.size
    assert_equal 0, user.favorited_articles.size
  end
end
