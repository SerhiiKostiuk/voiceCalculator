//
//  Converter.m
//  voiceCalculator
//
//  Created by Сергій Костюк on 10/10/17.
//  Copyright © 2017 Сергій Костюк. All rights reserved.
//

#import "Converter.h"

@implementation Converter

- (NSString *)wordsFromNumbersString:(NSString *)numbersString {
    NSNumberFormatter *formater = [[NSNumberFormatter alloc]init];
    formater.numberStyle = NSNumberFormatterSpellOutStyle;
    
    numbersString = [numbersString stringByReplacingOccurrencesOfString:@"×" withString:@"*"];
    numbersString = [numbersString stringByReplacingOccurrencesOfString:@"÷" withString:@"/"];
    numbersString = [numbersString.lowercaseString stringByReplacingOccurrencesOfString:@"one" withString:@"1"];
    
    NSExpression *expression = [NSExpression expressionWithFormat:numbersString];

    NSNumber *result = [expression expressionValueWithObject:nil context:nil];
    
    return [formater stringFromNumber:result];
}


@end
