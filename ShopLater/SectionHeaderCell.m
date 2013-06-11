//
//  SectionHeaderCell.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "SectionHeaderCell.h"

@interface SectionHeaderCell ()

@end

@implementation SectionHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setProviderLogo:(UIImage *)providerLogo
{
    _providerLogo = providerLogo;
    self.sectionImageView.image = providerLogo;
}

@end
