mongoose = require 'mongoose'
patchMongoose = require '..'
patchMongoose(mongoose)
async = require 'async'
{expect} = require 'chai'

schema = new mongoose.Schema
  name: String
Person = mongoose.model 'Person', schema

describe 'mongoose-lean', ->
  {bill} = {}

  expectFat = (fn, cb) ->
    async.waterfall [
      fn
      (person, next) ->
        expect(person).to.be.an.instanceof Person
        expect(person._id).to.be.an.instanceof mongoose.Types.ObjectId
        expect(person.id).to.equals person._id.toString()
        expect(person.name).to.be.a 'string'
        next()
    ], cb
  
  expectLean = (fn, cb) ->
    async.waterfall [
      fn
      (person, next) ->
        expect(person).not.to.be.an.instanceof Person
        expect(person.save).not.be.defined
        expect(person._id).to.be.an.instanceof mongoose.Types.ObjectId
        expect(person.id).to.equals person._id.toString()
        expect(person.name).to.be.a 'string'
        next()
    ], cb

  before (done) ->
    async.series [
      (next) ->
        mongoose.connect (process.env.MONGO_URL or 'mongodb://localhost/mongoose_lean-test'), next
      (next) ->
        bill = new Person name: 'Bill'
        bill.save next
    ], done

  after (done) ->
    mongoose.disconnect done

  describe 'create', ->

    it 'returns fat models', (done) ->
      expectFat (cb) ->
        Person.create name: 'Bob', cb
      , done

  describe 'findById', ->

    it 'returns lean models', (done) ->
      expectLean (cb) ->
        Person.findById bill._id, cb
      , done

  describe 'findOne', ->

    it 'returns lean models', (done) ->
      expectLean (cb) ->
        Person.findOne _id: bill._id, cb
      , done

  describe 'find', ->

    it 'returns lean models', (done) ->
      expectLean (cb) ->
        Person.find _id: bill._id, (err, people) ->
          cb err, people?[0]
      , done

  describe 'exec', ->

    it 'returns lean models', (done) ->
      expectLean (cb) ->
        Person.findOne(_id: bill._id).limit(1).exec cb
      , done

  describe 'fat', ->

    it 'returns fat models'
