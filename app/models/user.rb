class User < ApplicationRecord
  before_save{ self.email.downcase!}
  mount_uploader :image, ImagesUploader
    validates :name, presence: true, length: {maximum: 50}
    validates :email, presence: true, length: {maximum: 255},
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
            uniqueness: {case_sensitive: false}
  has_secure_password
  
  has_many :records, dependent: :destroy
  has_many :relationships,dependent: :destroy #自分がフォロしているUserへの参照
  has_many :likes,dependent: :destroy
  has_many :followings, through: :relationships, source: :follow ,dependent: :destroy #フォローしているユーザーを中間テーブルを経由して参照
  has_many :reverses_of_relationship, class_name: 'Relationship',foreign_key: 'follow_id' ,dependent: :destroy
  has_many :followers, through: :reverses_of_relationship, source: :user,dependent: :destroy #フォローされているUserを中間テーブルを経由して参照
  
  def follow(other_user)
    unless self == other_user #フォローしようとしているUserが自分ではないか検証
     self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_records
    Record.where(user_id: self.following_ids + [self.id]) #Record.where(user_id: フォローユーザー＋自分自身)
  end
  
  def like(other_user)
    unless self == other_user
      self.likes.find_or_create_by(like_id: other_user.id)
    end
  end
    
  def unlike(other_user)
    like = self.likes.find_by(like_id: other_user.id)
    like.destroy if like
  end
  
  def liking?(other_user)
    self.likings.include?(other_user)
  end
end