'use client'

import { FaRegThumbsUp, FaRegThumbsDown } from "react-icons/fa6";
import { MessageFeedback } from "@/lib/types";
import { sendFeedback } from "@/lib/feedback";
import { clsx } from 'clsx';

type Props = {
    responseId: string;
};

export const Feedback = ({ responseId }: Props) => {
    var iconsVisible: Boolean = false;
    var feedbackProvided: Boolean = false;

    if (responseId && responseId != '') {
        iconsVisible = true;
    }

    var divIconsClass=clsx('', {
        ['flex']: iconsVisible && !feedbackProvided,
        ['hidden']: !iconsVisible || (iconsVisible && feedbackProvided)
      })

    var divMessageClass=clsx('', {
        ['hidden']: !iconsVisible || (iconsVisible && !feedbackProvided),
        ['flex']: iconsVisible && feedbackProvided
      })


    async function ProvideFeedback(feedback: MessageFeedback) {
        await sendFeedback(feedback);
        feedbackProvided = true;
    }

    async function OnThumbsUpClick() {
        console.log("Thumbs up Clicked: " + responseId);
        const positiveFeedback: MessageFeedback = { responseId: responseId, feedback: 1, extra: { sentiment: 'positive', comments: '' } }
        await ProvideFeedback(positiveFeedback);
    }

    async function OnThumbsDownClick() {
        const negativeFeedback: MessageFeedback = { responseId: responseId, feedback: -1, extra: { sentiment: 'negative', comments: '' } }
        await ProvideFeedback(negativeFeedback);
    }

    return (
        <div>
            {responseId ? <p>&nbsp;</p> : ''}
            <div className={divIconsClass}>
                {iconsVisible ? <FaRegThumbsUp size='24px' onClick={OnThumbsUpClick} /> : ''}
                &nbsp;
                {iconsVisible ? <FaRegThumbsDown size='24px' onClick={OnThumbsDownClick} /> : ''}
            </div>
            <div className={divMessageClass}>
                {!iconsVisible ? 'Thank you for your feedback!' : ''}
            </div>
        </div>
    );
};

export default Feedback;
