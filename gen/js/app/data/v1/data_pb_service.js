// package: viam.app.data.v1
// file: app/data/v1/data.proto

var app_data_v1_data_pb = require("../../../app/data/v1/data_pb");
var grpc = require("@improbable-eng/grpc-web").grpc;

var DataService = (function () {
  function DataService() {}
  DataService.serviceName = "viam.app.data.v1.DataService";
  return DataService;
}());

DataService.TabularDataByFilter = {
  methodName: "TabularDataByFilter",
  service: DataService,
  requestStream: false,
  responseStream: false,
  requestType: app_data_v1_data_pb.TabularDataByFilterRequest,
  responseType: app_data_v1_data_pb.TabularDataByFilterResponse
};

DataService.BinaryDataByFilter = {
  methodName: "BinaryDataByFilter",
  service: DataService,
  requestStream: false,
  responseStream: false,
  requestType: app_data_v1_data_pb.BinaryDataByFilterRequest,
  responseType: app_data_v1_data_pb.BinaryDataByFilterResponse
};

DataService.BinaryDataByIDs = {
  methodName: "BinaryDataByIDs",
  service: DataService,
  requestStream: false,
  responseStream: false,
  requestType: app_data_v1_data_pb.BinaryDataByIDsRequest,
  responseType: app_data_v1_data_pb.BinaryDataByIDsResponse
};

exports.DataService = DataService;

function DataServiceClient(serviceHost, options) {
  this.serviceHost = serviceHost;
  this.options = options || {};
}

DataServiceClient.prototype.tabularDataByFilter = function tabularDataByFilter(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  var client = grpc.unary(DataService.TabularDataByFilter, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          var err = new Error(response.statusMessage);
          err.code = response.status;
          err.metadata = response.trailers;
          callback(err, null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
  return {
    cancel: function () {
      callback = null;
      client.close();
    }
  };
};

DataServiceClient.prototype.binaryDataByFilter = function binaryDataByFilter(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  var client = grpc.unary(DataService.BinaryDataByFilter, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          var err = new Error(response.statusMessage);
          err.code = response.status;
          err.metadata = response.trailers;
          callback(err, null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
  return {
    cancel: function () {
      callback = null;
      client.close();
    }
  };
};

DataServiceClient.prototype.binaryDataByIDs = function binaryDataByIDs(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  var client = grpc.unary(DataService.BinaryDataByIDs, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          var err = new Error(response.statusMessage);
          err.code = response.status;
          err.metadata = response.trailers;
          callback(err, null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
  return {
    cancel: function () {
      callback = null;
      client.close();
    }
  };
};

exports.DataServiceClient = DataServiceClient;

