class GenericFile < ActiveFedora::Base
  include Hydra::Works::FileSetBehavior

  contains "content", class_name: "ActiveFedora::File"
end