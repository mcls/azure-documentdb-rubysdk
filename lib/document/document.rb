require_relative '../context'
require_relative '../header/secure_header'
require_relative '../auth/master_token'
require_relative '../auth/resource_token'

module Azure
  module DocumentDB
    module Documents
      class Indexing
        class << self
          attr_reader :INCLUDE, :EXCLUDE
        end

        private
        @INCLUDE = "Include".freeze
        @EXCLUDE = "Exclude".freeze
      end
    end
    class Document
      def initialize context, rest_client, database_id, collection_id
        self.context = context
        self.rest_client = rest_client
        self.resource_type = "docs"
        self.secure_header = Azure::DocumentDB::SecureHeader.new context.master_token, resource_type
        self.database_id = database_id
        self.collection_id = collection_id
      end

      def create document_id, document, indexing_directive = nil
        body = { "id"=>document_id }.merge JSON.parse(document)
        header = header "post", collection_id
        header.merge! indexing_directive_hash(indexing_directive) if indexing_directive
        JSON.parse(rest_client.post url, body.to_json, header)
      end

      private
      attr_accessor :context, :rest_client, :resource_type, :secure_header, :database_id, :collection_id

      def url resource_id = nil
        target = "/" + resource_id if resource_id
        "#{context.endpoint}/dbs/#{database_id}/colls/#{collection_id}/#{resource_type}#{target}"
      end

      def header verb, resource_id, resource_token = nil
        return secure_header.header verb, resource_id unless resource_token
        resource_token.encode_header
      end

      def indexing_directive_hash indexing_directive
        { "x-ms-indexing-directive" => indexing_directive }
      end
    end
  end
end