# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user1 = User.create(name: "Hombre", email: "test@case.com", password: "123456", password_confirmation: "123456")
# portfolio1 = Portfolio.create(name: "Stocks", acc_number: "12345678", cash: 10000, opened_date: Date.today, user_id: user1.id)
