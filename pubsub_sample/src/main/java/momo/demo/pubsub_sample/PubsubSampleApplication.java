package momo.demo.pubsub_sample;


import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import com.google.cloud.pubsub.v1.Subscriber;
import com.google.api.gax.core.ExecutorProvider;
import com.google.api.gax.core.InstantiatingExecutorProvider;
import com.google.cloud.pubsub.v1.AckReplyConsumer;
import com.google.cloud.pubsub.v1.MessageReceiver;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.pubsub.v1.ProjectSubscriptionName;
import com.google.pubsub.v1.PubsubMessage;

public class PubsubSampleApplication {
	public static void main(String[] args) throws Exception {
		// TODO(developer): Replace these variables before running the sample.
		String projectId = "shawnho-demo-2023";
		String subscriptionId = "echo-read";
		subscribeAsyncExample(projectId, subscriptionId);
		//subscribeWithErrorListenerExample(projectId, subscriptionId);		
	}
	public static void subscribeAsyncExample(String projectId, String subscriptionId) {
		ProjectSubscriptionName subscriptionName =
			ProjectSubscriptionName.of(projectId, subscriptionId);
	
		// Instantiate an asynchronous message receiver.
		MessageReceiver receiver =
			(PubsubMessage message, AckReplyConsumer consumer) -> {
			  // Handle incoming message, then ack the received message.
			  System.out.println("Id: " + message.getMessageId());
			  System.out.println("Data: " + message.getData().toStringUtf8());
			  consumer.ack();
			  message
			  .getAttributesMap()
			  .forEach((key, value) -> System.out.println(key + " = " + value));
			  
			  System.out.printf("Done for Ack\n");
			};
		Subscriber subscriber = null;
		try {
		  subscriber = Subscriber.newBuilder(subscriptionName, receiver).build();
		  // Start the subscriber.
		  subscriber.startAsync().awaitRunning();
		  System.out.printf("Listening for messages on %s:\n", subscriptionName.toString());
		  // Keep Subscriber indefinitely to receive messages.
		  subscriber.awaitTerminated();
		} catch (IllegalStateException e) {
			System.out.println("Subscriber unexpectedly stopped: " + e);
		} finally {
			System.out.printf("Done for Subscriber\n");
			// Stop receiving messages.
			if (subscriber != null) {
				subscriber.stopAsync();
			}
	  	}
	  }
	  public static void subscribeWithErrorListenerExample(String projectId, String subscriptionId) {
		ProjectSubscriptionName subscriptionName =
			ProjectSubscriptionName.of(projectId, subscriptionId);
	
		// Instantiate an asynchronous message receiver.
		MessageReceiver receiver =
			(PubsubMessage message, AckReplyConsumer consumer) -> {
			  // Handle incoming message, then ack the received message.
			  System.out.println("Id: " + message.getMessageId());
			  System.out.println("Data: " + message.getData().toStringUtf8());
			  consumer.ack();
			};
	
		Subscriber subscriber = null;
		try {
		  // Provides an executor service for processing messages.
		  ExecutorProvider executorProvider =
			  InstantiatingExecutorProvider.newBuilder().setExecutorThreadCount(4).build();
	
		  subscriber =
			  Subscriber.newBuilder(subscriptionName, receiver)
				  .setExecutorProvider(executorProvider)
				  .build();
	
		  // Listen for unrecoverable failures. Rebuild a subscriber and restart subscribing
		  // when the current subscriber encounters permanent errors.
		  subscriber.addListener(
			  new Subscriber.Listener() {
				public void failed(Subscriber.State from, Throwable failure) {
				  System.out.println(failure.getStackTrace());
				  if (!executorProvider.getExecutor().isShutdown()) {
					subscribeWithErrorListenerExample(projectId, subscriptionId);
				  }
				}
			  },
			  MoreExecutors.directExecutor());
	
		  // Start the subscriber.
		  subscriber.startAsync().awaitRunning();
		  System.out.printf("Listening for messages on %s:\n", subscriptionName.toString());
		  // Allow the subscriber to run for 60m unless an unrecoverable error occurs.
		  subscriber.awaitTerminated(60, TimeUnit.MINUTES);
		} catch (TimeoutException timeoutException) {
			// Shut down the subscriber after 60m. Stop receiving messages.
			subscriber.stopAsync();
		} finally {
			System.out.printf("Done for Subscriber\n");
			if (subscriber != null) {
				subscriber.stopAsync();
			}
	  	}
	}
}