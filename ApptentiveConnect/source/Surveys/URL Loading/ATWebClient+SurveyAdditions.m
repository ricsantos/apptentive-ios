//
//  ATWebClient+SurveyAdditions.m
//  ApptentiveSurveys
//
//  Created by Andrew Wooster on 11/4/11.
//  Copyright (c) 2011 Apptentive. All rights reserved.
//

#import "ATWebClient+SurveyAdditions.h"
#import "ATWebClient_Private.h"
#import "ATAPIRequest.h"
#import "ATConversationUpdater.h"
#import "ATJSONSerialization.h"
#import "ATLegacySurveyResponse.h"
#import "ATSurveyResponse.h"
#import "ATURLConnection.h"

@implementation ATWebClient (SurveyAdditions)
- (ATAPIRequest *)requestForGettingSurveys {
	ATConversation *conversation = [ATConversationUpdater currentConversation];
	if (!conversation) {
		ATLogError(@"No current conversation.");
		return nil;
	}
	
	NSString *urlString = [NSString stringWithFormat:@"%@/surveys", [self baseURLString]];
	ATURLConnection *conn = [self connectionToGet:[NSURL URLWithString:urlString]];
	conn.timeoutInterval = 20.0;
	[self updateConnection:conn withOAuthToken:conversation.token];
	
	ATAPIRequest *request = [[ATAPIRequest alloc] initWithConnection:conn channelName:[self commonChannelName]];
	request.returnType = ATAPIRequestReturnTypeData;
	return [request autorelease];
}


- (ATAPIRequest *)requestForPostingLegacySurveyResponse:(ATLegacySurveyResponse *)surveyResponse {
	NSError *error = nil;
	NSString *postString = [ATJSONSerialization stringWithJSONObject:[surveyResponse apiJSON] options:ATJSONWritingPrettyPrinted error:&error];
	if (!postString && error != nil) {
		ATLogError(@"ATWebClient+SurveyAdditions: Error while encoding JSON: %@", error);
		return nil;
	}
	
	NSString *url = [self apiURLStringWithPath:@"records"];
	ATURLConnection *conn = nil;
	
	conn = [self connectionToPost:[NSURL URLWithString:url] JSON:postString];
	
	conn.timeoutInterval = 240.0;
	ATAPIRequest *request = [[ATAPIRequest alloc] initWithConnection:conn channelName:ATWebClientDefaultChannelName];
	request.returnType = ATAPIRequestReturnTypeJSON;
	return [request autorelease];
}

- (ATAPIRequest *)requestForPostingSurveyResponse:(ATSurveyResponse *)surveyResponse {
	ATConversation *conversation = [ATConversationUpdater currentConversation];
	if (!conversation) {
		ATLogError(@"No current conversation.");
		return nil;
	}
	
	NSError *error = nil;
	NSString *postString = [ATJSONSerialization stringWithJSONObject:[surveyResponse apiJSON] options:ATJSONWritingPrettyPrinted error:&error];
	if (!postString && error != nil) {
		ATLogError(@"ATWebClient+SurveyAdditions: Error while encoding JSON: %@", error);
		return nil;
	}
	NSString *path = [NSString stringWithFormat:@"surveys/%@/respond", surveyResponse.surveyID];
	NSString *url = [self apiURLStringWithPath:path];
	
	ATURLConnection *conn = [self connectionToPost:[NSURL URLWithString:url] JSON:postString];
	conn.timeoutInterval = 240.0;
	[self updateConnection:conn withOAuthToken:conversation.token];
	
	ATAPIRequest *request = [[ATAPIRequest alloc] initWithConnection:conn channelName:[self commonChannelName]];
	request.returnType = ATAPIRequestReturnTypeJSON;
	return [request autorelease];
}
@end

void ATWebClient_SurveyAdditions_Bootstrap() {
	NSLog(@"Loading ATWebClient_SurveyAdditions_Bootstrap");
}
