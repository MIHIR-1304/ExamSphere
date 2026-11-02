/**
 * SuperMemo SM-2 Spaced-Repetition Scheduling Algorithm
 * Implementation for ExamSphere Modular-Monolith Backend
 * Author: Mihir Mahato
 */

class SpacedRepetitionEngine {
  /**
   * Calculates the next review interval and new easiness factor (EF)
   * @param {number} quality - Rating from 0 (complete blackout) to 5 (perfect recall)
   * @param {number} repetition - Consecutive successful repetitions
   * @param {number} previousInterval - Previous interval in days
   * @param {number} previousEF - Previous Easiness Factor (default 2.5)
   * @returns {{ interval: number, repetition: number, easinessFactor: number, nextDueDate: Date }}
   */
  static calculateNextReview(quality, repetition = 0, previousInterval = 1, previousEF = 2.5) {
    if (quality < 0 || quality > 5) {
      throw new Error('Quality score must be an integer between 0 and 5');
    }

    let interval = 1;
    let nextRepetition = repetition;
    let ef = previousEF;

    // Calculate new Easiness Factor using SM-2 polynomial
    ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (ef < 1.3) {
      ef = 1.3; // Minimum boundary threshold for cognitive stability
    }

    if (quality >= 3) {
      // Successful recall
      if (nextRepetition === 0) {
        interval = 1;
      } else if (nextRepetition === 1) {
        interval = 6;
      } else {
        interval = Math.round(previousInterval * ef);
      }
      nextRepetition++;
    } else {
      // Failed recall: reset repetition chain but preserve updated EF
      nextRepetition = 0;
      interval = 1;
    }

    const nextDueDate = new Date();
    nextDueDate.setDate(nextDueDate.getDate() + interval);

    return {
      intervalDays: interval,
      repetitionNumber: nextRepetition,
      easinessFactor: parseFloat(ef.toFixed(2)),
      nextDueDate
    };
  }
}

module.exports = SpacedRepetitionEngine;
