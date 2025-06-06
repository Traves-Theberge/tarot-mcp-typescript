import Foundation
import Logging
import MCP

actor MockTransport: Transport {
  enum Failure: Swift.Error {
    case streamNotSet
  }

  enum Call: Equatable, Sendable {
    case connect
    case disconnect
    case send(Data)
    case receive
  }

  var logger: Logger
  var calls: [Call]

  private var stream: AsyncThrowingStream<Data, any Swift.Error>?

  init(
    logger: Logger? = nil,
    calls: [Call] = [],
    stream: AsyncThrowingStream<Data, any Swift.Error>? = nil
  ) {
    self.logger = logger ?? {
      var logger = Logger(label: "MockTransport")
      logger.logLevel = .critical
      return logger
    }()
    self.calls = calls
    self.stream = stream
  }

  func setStream(_ stream: AsyncThrowingStream<Data, any Swift.Error>) {
    self.stream = stream
  }

  func connect() async throws {
    calls.append(.connect)
  }

  func disconnect() async {
    calls.append(.disconnect)
  }

  func send(_ data: Data) async throws {
    calls.append(.send(data))
  }

  func receive() -> AsyncThrowingStream<Data, any Swift.Error> {
    calls.append(.receive)
    return stream.take() ?? AsyncThrowingStream { throw Failure.streamNotSet }
  }
}
