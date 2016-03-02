module FedoraMigrate
  module Works
    class FileSetMover < FedoraMigrate::ObjectMover
      ORIGINAL_FILE_DSID = 'content'
      def migrate_content_datastreams
        super
        if target.is_a?(GenericFile) && source.datastreams[ORIGINAL_FILE_DSID]
          original_file = target.build_original_file
          mover = FedoraMigrate::DatastreamMover.new(source.datastreams[ORIGINAL_FILE_DSID], original_file, options)
          target.original_file = original_file
          save
          report.content_datastreams << ContentDatastreamReport.new(ORIGINAL_FILE_DSID, mover.migrate)
        end
      end
    end
  end
end