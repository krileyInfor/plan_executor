module Crucible
  module Tests
    class ArgonautSprint1Test < BaseSuite
      attr_accessor :rc
      attr_accessor :conformance
      attr_accessor :searchParams
      attr_reader   :canSearchById

      def id
        'ArgonautSprint1Test'
      end

      def description
        'Argonaut Sprint 1 tests for testing Argonauts Sprint 1 goals: read patient by ID, search for patients by various demographics.'
      end

      def initialize(client1, client2=nil)
        super(client1, client2)
        @tags.append('argonaut')
      end

      def setup
        @id = ENV['patient_id']
        @searchParams = [:name, :family, :given, :identifier, :gender, :birthdate]
        @rc = FHIR::Patient
      end

      def get_patient_by_param(param, val, flag=true)
        assert val, "No #{param} for patient"
        options = {
          :search => {
            :flag => flag,
            :compartment => nil,
            :parameters => {
              param => val
            }
          }
        }
        reply = @client.search(@rc, options)
        assert_response_ok(reply)
        assert_bundle_response(reply)
        assert reply.resource.get_by_id(@id).equals?(@patient, ['_id', "text"]), 'Server returned wrong patient.'
      end

      def define_metadata(method)
        links "#{REST_SPEC_LINK}##{method}"
        links "#{BASE_SPEC_LINK}/#{@rc.name.demodulize.downcase}.html"
        validates resource: @rc.name.demodulize, methods: [method]
      end

      # [SprinklerTest("R001", "Result headers on normal read")]
      test 'AS001', 'Get patient by ID' do
        metadata {
          links "#{REST_SPEC_LINK}#read"
          requires resource: "Patient", methods: ["read", "search"]
          validates resource: "Patient", methods: ["read", "search"]
        }

        reply = @client.read(FHIR::Patient, @id)
        assert_response_ok(reply)
        assert_equal @id, reply.id, 'Server returned wrong patient.'
        @patient = reply.resource.get_by_id(@id)
        assert @patient
        warning { assert_valid_resource_content_type_present(reply) }
        warning { assert_last_modified_present(reply) }
      end

      test 'AS002', 'Search by ID' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param(:identifier, @patient[:identifier].first.try(:value))
      end

      test 'AS003', 'ID without search keyword' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param(:identifier, @patient[:identifier].first.try(:value), false)
      end

      test 'AS004', 'Search by Name' do
        metadata {
          define_metadata('search')
        }
        name = @patient[:name].first.try(:family).try(:first)
        get_patient_by_param(:name, name)
      end

      test 'AS005', 'Name without search keyword' do
        metadata {
          define_metadata('search')
        }
        name = @patient[:name].first.try(:family).try(:first)
        get_patient_by_param(:name, name, false)
      end

      test 'AS006', 'Search by Family' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param(:family, @patient[:name].first.try(:family).try(:first))
      end

      test 'AS007', 'Family without search keyword' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param(:family, @patient[:name].first.try(:family).try(:first), false)
      end

      test 'AS008', 'Search by Given' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param(:given, @patient[:name].first.try(:given).try(:first))
      end

      test 'AS009', 'Given without search keyword' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param(:given, @patient[:name].first.try(:given).try(:first), false)
      end

      test 'AS010', 'Search by Gender' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param('gender', @patient[:gender])
      end

      test 'AS011', 'Gender without search keyword' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param('gender', @patient[:gender], false)
      end

      test 'AS012', 'Search by Birthdate' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param('birthdate', @patient[:birthDate])
      end

      test 'AS013', 'Birthdate without search keyword' do
        metadata {
          define_metadata('search')
        }
        get_patient_by_param('birthdate', @patient[:birthDate], false)
      end

    end
  end
end
