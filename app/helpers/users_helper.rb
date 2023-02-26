module UsersHelper
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id} || https://www.gravatar.com/avatar/00000000000000000000000000000000?d=https://img.icons8.com/external-flaticons-flat-flat-icons/256/external-investor-home-based-business-flaticons-flat-flat-icons.png"
    image_tag(gravatar_url, alt: user.name, class: "gravatar avatar")
  end
end
