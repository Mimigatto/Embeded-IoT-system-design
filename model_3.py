#!/usr/bin/env python

import torch

class TinyModel(torch.nn.Module):
    def __init__(self) -> None:
        super().__init__()

        self.conv1 = torch.nn.Sequential(
            torch.nn.Conv2d(1, 1, (17, 1), (7, 1), dilation=4),
            torch.nn.ReLU(),
            torch.nn.Flatten(),
        )

        self.fcn = torch.nn.Sequential(
            torch.nn.Dropout(p=0.29, inplace=False),
            torch.nn.Linear(in_features=170, out_features=40, bias=True),
            torch.nn.ReLU(),
            torch.nn.Dropout(p=0.23, inplace=False),
            torch.nn.Linear(in_features=40, out_features=2, bias=True),
        )

    def forward(self, x):
        return self.fcn(self.conv1(x))

    def features(self, x):
        return self.conv1(x)


if __name__ == "__main__":
    m = TinyModel()(torch.randn((1, 1, 1250, 1)))
